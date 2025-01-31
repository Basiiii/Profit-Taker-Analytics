//! # Run Deletion Module  
//!  
//! This module provides functionality to delete a run from the database,  
//! ensuring that all related data is also removed if cascading delete rules are in place.  
//!  
//! ## Features  
//! - Deletes a run by its ID.  
//! - Uses SQLite’s cascading delete functionality to remove associated data.  
//! - Ensures safe execution by retrieving the global database path dynamically.  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::delete_run::delete_run;
//!
//! let run_id = 42;
//! if let Err(e) = delete_run(run_id) {
//!     eprintln!("Failed to delete run: {}", e);
//! }
//! ```  
//!  
//! ## Notes  
//! - The function relies on `get_db_path()` to retrieve the active database path.  
//! - Ensure that foreign key constraints are set up correctly in the database schema.  

use rusqlite::{Connection, Result};
use crate::connection::get_db_path;

/// Deletes a run from the database, along with all related data.
///
/// This function uses the cascading delete functionality defined in the database schema.
///
/// # Arguments
/// - `run_id`: The ID of the run to delete.
///
/// # Returns
/// - `Ok(())` if the run was successfully deleted.
/// - An `Err` if there was a problem executing the deletion query.
pub fn delete_run(run_id: i32) -> Result<()> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Open a connection to the database
    let conn = Connection::open(&db_path)?;

    // Prepare and execute the delete query
    conn.execute("DELETE FROM runs WHERE id = ?", &[&run_id])?;

    // Return success
    Ok(())
}
