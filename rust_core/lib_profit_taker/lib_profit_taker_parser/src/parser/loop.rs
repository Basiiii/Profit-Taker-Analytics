//! Main loop that reads the log file line by line, and processes the lines,
//! passing them to `parse_run()` if it finds a run

#![warn(clippy::nursery, clippy::pedantic)]

use std::fs::File;
use std::io::{self, BufRead, BufReader, Seek, SeekFrom};
use std::time::Duration;
use std::{fs, thread};

use crate::cli::pretty_print_run;
use crate::constants::{HEIST_START, LOG_START_TIME};
use crate::line_utils::get_log_time;
use crate::parser::events::parse_run;
use crate::parser_state::ParserState;
use lib_profit_taker_core::Run;
use lib_profit_taker_database::queries::insert_run::insert_run;

/// Main loop that reads the log file line by line, and processes the lines,
/// checking for runs and passing them to `parse_run()` if it finds one
///
/// # Errors
///
/// Returns an error if the file cannot be opened or read
pub fn log_reading(path: &str, mut pos: u64, mut run_number: i32) -> io::Result<()> {
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
        let mut line = String::new();

        // Check if the file has been reset, set seeking position to start of file if so
        let new_size = fs::metadata(path)?.len();
        if new_size < known_size {
            println!("Restart detected.");
            pos = 0;
            println!(
                "Successfully reconnected to EE.log. Now listening for new Profit-Taker runs."
            );
        }
        known_size = new_size;

        while reader.read_line(&mut line)? > 0 {
            // Logger sometimes commits incomplete lines, causing reading errors,
            // so we wait a little and try again if the line is incomplete
            if !line.ends_with('\n') {
                thread::sleep(Duration::from_millis(10));
                continue;
            }

            // Set the log start time to have consistent timestamps for runs
            if line.contains(LOG_START_TIME) {
                parser_state.log_start_time = get_log_time(&line);
            }

            // Check if a new run has started, initialize a new run if so
            if line.contains(HEIST_START) && current_run.is_none() {
                run_number += 1; //TODO remove this when done because it's just for testing
                let new_run = Run::new(run_number);
                current_run = Some(new_run);
                println!("Run #{run_number} found, analysing...");
                parser_state.run_ended = false;
            }

            // Process line if inside a run
            if let Some(ref mut run) = current_run {
                parse_run(run, &line, &mut parser_state);

                // Check if the run has ended, save the run to the database and reset the current run
                if parser_state.run_ended {
                    println!("{}", pretty_print_run(run)); // for debugging purposes

                    // Insert the run into the database
                    if let Err(e) = insert_run(run) {
                        eprintln!("Error inserting run: {e}");
                    }

                    // Reset the current run
                    current_run = None;

                    // Reset temporary run variables for the next run
                    parser_state = ParserState::new();
                    println!("Done analysing run #{run_number}");
                }
            }

            pos = reader.seek(SeekFrom::Current(0))?;
            line.clear();
        }
        thread::sleep(Duration::from_millis(100));
    }
}
