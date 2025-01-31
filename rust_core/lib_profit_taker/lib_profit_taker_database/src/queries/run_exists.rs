//! # Check Run Existence Module  
//!  
//! This module provides functionality to check whether a run  
//! with a given ID exists in the database.  
//!  
//! ## Features  
//! - Queries the database for the existence of a specific run ID.  
//! - Returns `true` if the run exists, `false` otherwise.  
//! - Uses `rusqlite` for efficient database queries.  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::run_exists::run_exists;
//!
//! let run_id = 10;
//! match run_exists(run_id) {
//!     Ok(true) => println!("Run exists."),
//!     Ok(false) => println!("Run does not exist."),
//!     Err(e) => eprintln!("Error checking run existence: {}", e),
//! }
//! ```  

use rusqlite::{Connection, Result};
use crate::connection::get_db_path;

/// Checks whether a run with the given ID exists in the database.
///
/// This function establishes a connection to the database and checks for the existence
/// of the run with the specified `run_id`.
///
/// # Arguments
/// * `run_id` - The ID of the run to check.
///
/// # Returns
/// * `Ok(true)` - If the run exists.
/// * `Ok(false)` - If the run does not exist.
/// * `Err` - If there is an error connecting to the database or executing the query.
pub fn run_exists(run_id: i32) -> Result<bool> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Open a connection to the database
    let conn = Connection::open(&db_path)?;

    // Prepare and execute the query to check if the run exists
    let mut stmt = conn.prepare("SELECT EXISTS(SELECT 1 FROM runs WHERE id = ?)")?;
    let exists: i32 = stmt.query_row([run_id], |row| row.get(0))?;

    Ok(exists != 0)
}
