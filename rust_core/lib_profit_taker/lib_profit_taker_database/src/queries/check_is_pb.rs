//! # Check if Run is PB Module  
//!  
//! This module provides functionality to check if a given run ID is the Personal Best (PB).  
//!  
//! ## Features  
//! - Determines if the specified run ID has the lowest `total_time` in the database.  
//! - Uses `rusqlite` for efficient database queries.  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::check_is_pb::is_pb;
//!
//! let run_id = 10;
//! match is_pb(run_id) {
//!     Ok(true) => println!("This run is the PB!"),
//!     Ok(false) => println!("This run is not the PB."),
//!     Err(e) => eprintln!("Error checking PB status: {}", e),
//! }
//! ```  

use rusqlite::{Connection, Result};
use crate::connection::get_db_path;


/// Checks if the given run ID is the Personal Best (PB).
///
/// A run is considered the PB if it has the lowest `total_time` in the database,
/// is a solo run, is not aborted, and is not bugged.
///
/// # Arguments
/// * `run_id` - The ID of the run to check.
///
/// # Returns
/// * `Ok(true)` - If the run is the PB.
/// * `Ok(false)` - If the run is not the PB.
/// * `Err` - If there is an error connecting to the database or executing the query.
pub fn is_pb(run_id: i32) -> Result<bool> {
  let db_path = get_db_path()?;
  let conn = Connection::open(&db_path)?;

  let mut stmt = conn.prepare(
      "SELECT EXISTS (
          SELECT 1 FROM runs
          WHERE id = ? 
          AND total_time = (
              SELECT MIN(total_time) FROM runs 
              WHERE solo_run = 1 AND aborted_run = 0 AND bugged_run = 0
          )
          AND solo_run = 1 
          AND aborted_run = 0 
          AND bugged_run = 0
      )",
  )?;

  let is_pb: bool = stmt.query_row([run_id], |row| row.get(0))?;
  Ok(is_pb)
}
