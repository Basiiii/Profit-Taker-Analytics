//! This module is responsible for initializing the parser for reading and processing the Warframe EE.log file.
//! It spawns a new thread to handle the log reading asynchronously and returns a handle to manage the thread.
//!
//! The function `initialize_parser` performs the following:
//! 1. Retrieves the path to the log file from the system's environment variable (`ENV_PATH`) and the constant `LOG_PATH`.
//! 2. Opens the log file and prepares a buffered reader to efficiently read it.
//! 3. Seeks to the beginning of the file.
//! 4. Spawns a new thread to parse the log file asynchronously.
//! 5. Returns a `JoinHandle` for the spawned thread to allow the caller to join (wait) for the thread's completion.

use std::thread::{self, JoinHandle};
use std::env;
use std::fs::File;
use std::io::{BufReader, Seek, SeekFrom};
use crate::constants::{ENV_PATH, LOG_PATH};
use crate::parser::r#loop::log_reading;

/// Initializes the log parser by setting up the path to the log file and spawning a new thread to process it.
/// 
/// # Steps:
/// 
/// 1. Retrieves the environment variable (`ENV_PATH`) that holds the path to the directory containing the log file.
/// 2. Combines the environment variable value with the constant `LOG_PATH` to create the full path to the log file.
/// 3. Attempts to open the log file located at the constructed path.
/// 4. Reads the file and seeks to the beginning.
/// 5. Spawns a new thread to run the `log_reading` function, which processes the log file asynchronously.
/// 6. Returns a `JoinHandle<()>` for the spawned thread, allowing the caller to manage or join the thread later.
/// 
/// # Returns:
/// - `Ok(JoinHandle<()>)`: A `JoinHandle` representing the spawned thread if the initialization is successful.
/// - `Err(Box<dyn std::error::Error>)`: A `Box` containing any error that occurred during the initialization, such as issues with
///   retrieving the environment variable, opening the file, seeking the file, or spawning the thread.
/// 
/// # Example:
/// ```rust
/// match initialize_parser() {
///     Ok(handle) => {
///         // Do something with the thread handle, like joining the thread:
///         handle.join().expect("Thread failed");
///     },
///     Err(e) => {
///         eprintln!("Error initializing the parser: {e}");
///     }
/// }
/// ```
pub fn initialize_parser() -> Result<JoinHandle<()>, Box<dyn std::error::Error>> {
    // Build the path to the log file from environment variable and constant.
    let env_path = env::var(ENV_PATH)?;
    let path = format!("{}{}", env_path, LOG_PATH);

    // Open the log file.
    let file = File::open(&path)?;
    let mut reader = BufReader::new(file);

    // Seek to the beginning of the file.
    let pos = reader.seek(SeekFrom::Start(0))?;

    // Spawn the parser in a separate thread and return the handle.
    let handle = thread::spawn(move || {
        if let Err(e) = log_reading(&path, pos) {
            eprintln!("Error running the parser: {e}");
        }
    });

    Ok(handle)
}
