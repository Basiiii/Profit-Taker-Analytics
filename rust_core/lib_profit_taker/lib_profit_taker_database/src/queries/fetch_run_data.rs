//! # Fetch Run Data Module  
//!  
//! This module provides functionality to retrieve detailed run data  
//! from the database using the `RunRepository`.  
//!  
//! ## Features  
//! - Retrieves a complete `Run` record by ID.  
//! - Uses repository-based data access for maintainability.  
//! - Provides an easy-to-use API for external calls (e.g., from Flutter).  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::fetch_run_data::fetch_run_from_db;
//!
//! let run_id = 10;
//! match fetch_run_from_db(run_id) {
//!     Ok(run) => println!("Run found: {:?}", run),
//!     Err(e) => eprintln!("Error fetching run: {}", e),
//! }
//! ```  

use rusqlite::Connection;
use lib_profit_taker_core::Run;
use crate::{error::Result, repositories::RunRepository};
use crate::connection::get_db_path;

/// Retrieves a `Run` record from the database based on the provided run ID.
/// 
/// This function establishes a connection to the `SQLite` database and queries for the
/// corresponding `Run` entry using the `RunRepository`. It abstracts the database access
/// logic, making it convenient for external callers (e.g., from a Flutter application).
/// 
/// # Arguments
/// - `run_id` - The unique identifier of the run to fetch.
///
/// # Returns
/// - `Ok(Run)` if the run is found in the database.
/// - `Err` if the run does not exist or if an error occurs while accessing the database.
/// 
/// # Errors
/// - Returns an error if there is an issue with the database connection.
/// - Returns an error if the specified run ID does not exist in the database.
/// 
/// # Example
/// ```rust
/// use crate::queries::fetch_run_data::fetch_run_from_db;
///
/// let run_id = 42;
/// match fetch_run_from_db(run_id) {
///     Ok(run) => println!("Fetched run: {:?}", run),
///     Err(e) => eprintln!("Error retrieving run: {}", e),
/// }
/// ```
pub fn fetch_run_from_db(run_id: i32) -> Result<Run> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Try to open the connection to the database
    let conn = Connection::open(&db_path)?;

    // Create the RunRepository and use it to fetch the `Run`
    let run_repo = RunRepository::new(&conn);
    run_repo.get_run(run_id)
}
