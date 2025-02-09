//! Main loop that reads the log file line by line, and processes the lines,
//! passing them to `parse_run()` if it finds a run
//! # Log File Reader
//!
//! This module provides the main loop for reading and processing a log file line by line.
//! It detects specific events in the log, processes them, and inserts corresponding data
//! into a database. The module also handles scenarios like log file resets and ensures proper
//! handling of incomplete log lines.
//!
//! ## Features
//! - Monitors a log file continuously.
//! - Detects the start and end of runs (e.g., heists).
//! - Processes log lines for extracting information.
//! - Inserts parsed data into a database.
//!
//! ## Key Concepts
//! - **Current Run**: Represents an instance of a "run" found in the log file. Operations are performed
//!   on this run while it is active.
//! - **Parser State**: Used to manage temporary variables required while parsing a run, including
//!   detecting when a run starts or ends.
//! - **Log File Resets**: Detects log file resets and adjusts the reading position to prevent errors.
//!
//! ## Warning
//! The function is designed for streams of log files where incomplete lines may appear. It includes
//! handling for such cases by introducing short delays to ensure the lines are fully committed before parsing.

#![warn(clippy::nursery, clippy::pedantic)]

use std::fs::File;
use std::io::{self, BufRead, BufReader, Seek, SeekFrom};
use std::time::Duration;
use std::{fs, thread};

//use crate::cli::pretty_print_run;
use crate::constants::{HEIST_START, LOG_START_TIME};
use crate::line_utils::get_log_time;
use crate::parser::events::parse_run;
use crate::parser_state::ParserState;
use lib_profit_taker_core::Run;
use lib_profit_taker_database::queries::fetch_latest_run::fetch_latest_run_id;
use lib_profit_taker_database::queries::insert_run::insert_run;


/// Main loop that reads the log file line by line, and processes them, with checks for events like log resets.
///
/// # Arguments
/// * `path` - A string slice that holds the file path to the log file.
/// * `pos` - A mutable starting position in the file used for resuming reading.
///
/// # Returns
/// Returns an `io::Result<()>`, which can be an error if the file cannot be opened, read, or processed.
///
/// # Details
/// This function:
/// - Continuously monitors the log file to check for specific patterns or events.
/// - Detects file resets, sets the parsing position to the beginning, and continues reading.
/// - Handles partially committed lines in the log by introducing retries with short delays.
/// - Identifies runs in the log file and processes the data using the `parse_run()` function.
/// - Inserts finished runs into a database using `insert_run()`.
/// - Ensures proper allocation of resources and resets temporary variables when a run ends or a reset occurs.
///
/// # Errors
/// This function propagates any I/O-related errors that occur during file operations.
/// Potential errors include issues in opening the log file, reading the file, or seeking a specific position.
pub fn log_reading(path: &str, mut pos: u64) -> io::Result<()> {
    // current run is an option so that parse_run is only called when a run is found
    let mut current_run: Option<Run> = None;

    // parser state is used to keep track temporary variables used while parsing a run
    let mut parser_state = ParserState::new();

    // get the size of the log file ot account for log file resets
    let mut known_size = fs::metadata(path)?.len();

    // Main loop, reads the log file line by line, and processes the lines
    // calls parse_run when a run is found, and updates the current run with the information
    loop {
        let mut file = File::open(path)?;
        file.seek(SeekFrom::Start(pos))?;
        let mut reader = BufReader::new(file);

        let mut raw_line = Vec::new();

        // Check if the file has been reset, set seeking position to start of file if so
        let new_size = fs::metadata(path)?.len();
        if new_size < known_size {
            //println!("Restart detected.");
            pos = 0;
            //println!(
            //    "Successfully reconnected to EE.log. Now listening for new Profit-Taker runs."
            //);
        }
        known_size = new_size;

        while reader.read_until(b'\n', &mut raw_line)? > 0 {
            
            let line = match String::from_utf8(raw_line.clone()) { 
                Ok(l) => l,
                Err(e) => {
                    eprintln!("UTF-8 encoding error: {e}, waiting and rereading line...");
                    thread::sleep(Duration::from_millis(10));
                    continue;
                }
            };

            // Logger sometimes commits incomplete lines, causing reading errors,
            // so we wait a little and try again if the line is incomplete
            if !line.ends_with('\n') {
                thread::sleep(Duration::from_millis(10));
                continue;
            }

            // Set the log start time to have consistent timestamps for runs,
            // should only happen once per log file
            if line.contains(LOG_START_TIME) {
                parser_state.log_start_time = get_log_time(&line);
                //println!("Log start time set to: {}", parser_state.log_start_time);
            }

            // Check if a new run has started, initialize a new run if so
            if line.contains(HEIST_START) && current_run.is_none() {
                let new_run = Run::new();
                current_run = Some(new_run);
                //println!("Run found, analysing...");
                parser_state.run_ended = false;
            }

            // Process line if inside a run
            if let Some(ref mut run) = current_run {
                parse_run(run, &line, &mut parser_state);

                // Check if the run has ended, save the run to the database and reset the current run
                if parser_state.run_ended {
                    //println!("{}", pretty_print_run(run)); // for debugging purposes
                    
                    // Fetch the latest run ID from the database
                    let latest_run_id = match fetch_latest_run_id() {
                        Ok(Some(run_id)) => run_id,
                        Ok(None) => 0,
                        Err(e) => {
                            eprintln!("Failed to fetch latest run: {e}");
                            0
                        }
                    };
                    
                    // Set the run name based on the latest run ID
                    run.run_name = format!("Run #{}", latest_run_id + 1);

                    // Insert the run into the database
                    if let Err(e) = insert_run(run) {
                        eprintln!("Error inserting run: {e}");
                    }

                    // Reset the current run
                    current_run = None;

                    // Reset temporary run variables for the next run
                    parser_state = ParserState::with_log_start_time(parser_state.log_start_time);
                    //println!("Done analysing run");
                }
            }

            pos = reader.seek(SeekFrom::Current(0))?;
            raw_line.clear();
        }
        thread::sleep(Duration::from_millis(100));
    }
}
