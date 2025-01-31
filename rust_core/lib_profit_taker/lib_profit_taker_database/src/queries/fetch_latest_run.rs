//! # Fetch Latest Run Module  
//!  
//! This module provides functionality to retrieve the ID of the latest (most recent) run  
//! recorded in the database.  
//!  
//! ## Features  
//! - Queries the database for the highest run ID.  
//! - Returns `None` if no runs exist.  
//! - Uses `rusqlite` for efficient data retrieval.  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::fetch_latest_run::fetch_latest_run_id;
//!
//! match fetch_latest_run_id() {
//!     Ok(Some(run_id)) => println!("Latest run ID: {}", run_id),
//!     Ok(None) => println!("No runs found in the database."),
//!     Err(e) => eprintln!("Failed to fetch latest run: {}", e),
//! }
//! ```  

use rusqlite::{Connection, OptionalExtension, Result};
use crate::connection::get_db_path;

/// Fetches the ID of the latest run in the database.
///
/// This function establishes a connection to the database and retrieves the highest run ID.
///
/// # Returns
/// * `Ok(Some(i32))` - The ID of the latest run if it exists.
/// * `Ok(None)` - If no runs exist in the database.
/// * `Err` - If there is an error connecting to the database or executing the query.
pub fn fetch_latest_run_id() -> Result<Option<i32>> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Open a connection to the database
    let conn = Connection::open(&db_path)?;

    // Prepare and execute the query to get the latest run ID
    let mut stmt = conn.prepare("SELECT id FROM runs ORDER BY id DESC LIMIT 1")?;
    let result = stmt.query_row([], |row| row.get(0)).optional()?;

    Ok(result)
}
