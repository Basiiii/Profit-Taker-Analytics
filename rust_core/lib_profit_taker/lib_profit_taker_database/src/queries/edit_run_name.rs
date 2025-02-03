//! # Edit Run Name Module  
//!  
//! This module provides functionality to update the name of a `Run` in the database  
//! using the `RunRepository`.  
//!  
//! ## Features  
//! - Updates the `run_name` field for a specific `Run`.  
//! - Uses repository-based data access for maintainability.  
//! - Provides an easy-to-use API for external calls (e.g., from a Flutter app).  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::edit_run_name::edit_run_name;
//! 
//! let run_id = 1; // The ID of the run to update
//! let new_name = "New Run Name"; // The new name for the run
//! if let Err(e) = edit_run_name(run_id, new_name) {
//!     eprintln!("Error updating run name: {}", e);
//! }
//! ```  

use rusqlite::Connection;
use crate::{error::Result, repositories::RunRepository};
use crate::connection::get_db_path;

/// Updates the `run_name` for a specific `Run` in the database.
/// 
/// This function establishes a connection to the `SQLite` database and utilizes the
/// `RunRepository` to update the `run_name` for the provided `run_id`. 
/// It is designed to be easy to use in external applications, such as a Flutter-based app.
/// 
/// # Arguments
/// - `run_id` - The ID of the `Run` to be updated.
/// - `new_run_name` - The new name to set for the `Run`.
/// 
/// # Returns
/// - `Ok(())` if the update was successful.
/// - `Err` if there is an error during the update process, such as a database connection failure.
/// 
/// # Errors
/// - Returns an error if there is an issue with the database connection.
/// - Returns an error if the update fails due to the `Run` not existing.
/// 
/// # Example
/// ```rust
/// use crate::queries::edit_run_name::edit_run_name;
/// 
/// let run_id = 1; // The ID of the run to update
/// let new_name = "New Run Name"; // The new name for the run
/// if let Err(e) = edit_run_name(run_id, new_name) {
///     eprintln!("Error updating run name: {}", e);
/// }
/// ```
pub fn edit_run_name(run_id: i32, new_run_name: &str) -> Result<()> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Try to open the connection to the database
    let conn = Connection::open(&db_path)?;

    // Create the RunRepository and use it to update the run name
    let run_repo = RunRepository::new(&conn);
    run_repo.update_run_name(run_id, new_run_name)
}
