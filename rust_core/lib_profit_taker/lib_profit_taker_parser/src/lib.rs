//! This library takes responsibility for actually parsing provided logs into usable data.

#![warn(clippy::nursery, clippy::pedantic)]

use std::thread;
use std::{env};
use std::fs::File;
use std::io::{BufReader, Seek, SeekFrom};
use crate::constants::{ENV_PATH, LOG_PATH};
use crate::parser::r#loop::log_reading;

mod parser_state;
pub mod cli;
pub mod constants;
pub mod line_utils;
pub mod parser;

/// Main function that initializes the parser and starts the loop in a separate thread
pub fn initialize_parser() -> thread::Result<()> {

    //println!("Initializing Profit-Taker parser...");
    
    // Get the path to the log file, depending on the OS
    // supported so far (in theory): Windows, Linux //TODO: check linux implementation, maybe add MacOS
    let path = format!(
        "{}{}",
        env::var(ENV_PATH).expect("cant find path to log in your OS"),
        LOG_PATH
    );
    let file = File::open(&path).expect("Log file not found");
    let mut reader = BufReader::new(file);
    let pos = reader.seek(SeekFrom::Start(0)).expect("Error seeking to start of file");
    //println!("Log file found at: {path}");
    //println!("Now listening for Profit-Taker runs...");
    
    let builder = thread::Builder::new();

    // Start the main loop in a separate thread
    let handler = builder.spawn(move || {
        log_reading(&path, pos).expect("Error running the parser");
    }).unwrap();
    
    handler.join()
}
