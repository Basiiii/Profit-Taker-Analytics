//! # Latest Run Module
//!
//! This module provides functionality to check if a given run is the latest run
//! in the database, based on the highest timestamp.
//!
//! ## Features
//! - Determines if a specific run is the most recent.
//! - Uses SQLite to retrieve and compare run timestamps.
//! - Ensures safe execution by dynamically retrieving the global database path.
//!
//! ## Usage
//! ```rust
//! use crate::queries::latest_run::is_latest_run;
//!
//! let run_id = 42;
//! match is_latest_run(run_id) {
//!     Ok(true) => println!("Run {} is the latest.", run_id),
//!     Ok(false) => println!("Run {} is not the latest.", run_id),
//!     Err(e) => eprintln!("Error checking latest run: {}", e),
//! }
//! ```
//!
//! ## Notes
//! - The function relies on `get_db_path()` to retrieve the active database path.
//! - Ensure the `runs` table has correctly stored timestamps.

use rusqlite::{Connection, OptionalExtension, Result};
use crate::connection::get_db_path;

/// Checks if a given run is the latest run in the database.
///
/// # Arguments
/// - `run_id`: The ID of the run to check.
///
/// # Returns
/// - `Ok(true)` if the run is the latest.
/// - `Ok(false)` if the run is not the latest or does not exist.
/// - An `Err` if there was an error executing the query.
pub fn is_latest_run(run_id: i32) -> Result<bool> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Open a connection to the database
    let conn = Connection::open(&db_path)?;

    // Query to get the latest run's ID based on the highest timestamp
    let mut stmt = conn.prepare("SELECT id FROM runs ORDER BY time_stamp DESC LIMIT 1")?;
    let latest_run_id: Option<i32> = stmt.query_row([], |row| row.get(0)).optional()?;

    // Check if the latest run ID matches the provided run_id
    Ok(latest_run_id == Some(run_id))
}
