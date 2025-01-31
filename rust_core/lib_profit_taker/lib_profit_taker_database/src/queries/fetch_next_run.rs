//! # Fetch Next Run Module  
//!  
//! This module provides functionality to retrieve the ID of the next run  
//! relative to a given run ID.  
//!  
//! ## Features  
//! - Retrieves the next run in ascending order.  
//! - Returns `None` if no next run exists.  
//! - Uses `rusqlite` for efficient database queries.  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::fetch_next_run::fetch_next_run_id;
//!
//! let current_run_id = 10;
//! match fetch_next_run_id(current_run_id) {
//!     Ok(Some(next_run_id)) => println!("Next run ID: {}", next_run_id),
//!     Ok(None) => println!("No next run found."),
//!     Err(e) => eprintln!("Error fetching next run: {}", e),
//! }
//! ```  

use rusqlite::{Connection, OptionalExtension, Result};
use crate::connection::get_db_path;

/// Fetches the ID of the next run relative to the given run ID.
///
/// This function establishes a connection to the database and retrieves the ID of the run
/// that follows the specified `current_run_id` in order.
///
/// # Arguments
/// * `current_run_id` - The ID of the current run.
///
/// # Returns
/// * `Ok(Some(i32))` - The ID of the next run if it exists.
/// * `Ok(None)` - If there is no next run.
/// * `Err` - If there is an error connecting to the database or executing the query.
pub fn fetch_next_run_id(current_run_id: i32) -> Result<Option<i32>> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Open a connection to the database
    let conn = Connection::open(&db_path)?;

    // Prepare and execute the query to get the next run ID
    let mut stmt = conn.prepare("SELECT id FROM runs WHERE id > ? ORDER BY id ASC LIMIT 1")?;
    let result = stmt.query_row([current_run_id], |row| row.get(0)).optional()?;

    Ok(result)
}
