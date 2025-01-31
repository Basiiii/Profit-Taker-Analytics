//! # Insert Run Module  
//!  
//! This module provides functionality to insert a `Run` and its related data  
//! into the database using the `RunRepository`.  
//!  
//! ## Features  
//! - Inserts a complete `Run` record.  
//! - Uses repository-based data access for maintainability.  
//! - Provides an easy-to-use API for external calls (e.g., from Flutter).  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::insert_run::insert_run;
//! use lib_profit_taker_core::Run;
//!
//! let run = Run::new(...); // Fill in required fields  
//! if let Err(e) = insert_run(&run) {
//!     eprintln!("Error inserting run: {}", e);
//! }
//! ```  

use rusqlite::Connection;
use lib_profit_taker_core::Run;
use crate::{error::Result, repositories::RunRepository};
use crate::connection::get_db_path;

/// Inserts a `Run` record and its related data into the database.
/// 
/// This function establishes a connection to the SQLite database and utilizes the
/// `RunRepository` to insert the provided `Run` and any associated data. It is designed 
/// to be easy to use in external applications, such as a Flutter-based app.
/// 
/// # Arguments
/// - `run` - A reference to the `Run` object that contains the data to be inserted into the database.
/// 
/// # Returns
/// - `Ok(())` if the insertion was successful.
/// - `Err` if there is an error during the insertion process, such as a database connection failure 
///   or any issues with the data format.
/// 
/// # Errors
/// - Returns an error if there is an issue with the database connection.
/// - Returns an error if the insertion fails due to a constraint violation or other issues.
/// 
/// # Example
/// ```rust
/// use crate::queries::insert_run::insert_run;
/// use lib_profit_taker_core::Run;
///
/// let run = Run::new(...); // Initialize the Run object with the necessary data
/// if let Err(e) = insert_run(&run) {
///     eprintln!("Error inserting run: {}", e);
/// }
/// ```
pub fn insert_run(run: &Run) -> Result<()> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Try to open the connection to the database
    let conn = Connection::open(&db_path)?;

    // Create the RunRepository and use it to insert the `Run` and related data
    let run_repo = RunRepository::new(&conn);
    run_repo.insert_run(run)
}
