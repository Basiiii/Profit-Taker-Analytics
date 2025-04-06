//! # Fetch PB Times Module  
//!  
//! This module provides functionality to retrieve the times of the Personal Best (PB) run.  
//!  
//! ## Features  
//! - Fetches the `total_time`, `total_flight_time`, `total_shield_time`, `total_leg_time`,  
//!   `total_body_time`, and `total_pylon_time` of the PB run.  
//! - Uses `rusqlite` for efficient database queries.  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::fetch_pb_times::fetch_pb_times;
//!
//! match fetch_pb_times() {
//!     Ok(Some(pb_times)) => println!("PB Times: {:?}", pb_times),
//!     Ok(None) => println!("No PB run found."),
//!     Err(e) => eprintln!("Error fetching PB times: {}", e),
//! }
//! ```  

use rusqlite::{Connection, OptionalExtension, Result};
use crate::connection::get_db_path;

/// Represents the times of a run.
#[derive(Debug)]
pub struct RunTimes {
    pub run_id: i32,
    pub total_time: f64,
    pub total_flight_time: f64,
    pub total_shield_time: f64,
    pub total_leg_time: f64,
    pub total_body_time: f64,
    pub total_pylon_time: f64,
}

/// Fetches the times of the Personal Best (PB) run.
/// The PB run must be a solo run, not aborted, and not bugged.
///
/// # Returns
/// * `Ok(Some(RunTimes))` - The times of the PB run if it exists.
/// * `Ok(None)` - If no PB run exists.
/// * `Err` - If there is an error connecting to the database or executing the query.
pub fn fetch_pb_times() -> Result<Option<RunTimes>> {
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path)?;

    let mut stmt = conn.prepare(
        "SELECT id, total_time, total_flight_time, total_shield_time, total_leg_time, total_body_time, total_pylon_time
         FROM runs
         WHERE solo_run = 1 AND aborted_run = 0 AND bugged_run = 0
         ORDER BY total_time ASC
         LIMIT 1",
    )?;

    let result = stmt
        .query_row([], |row| {
            Ok(RunTimes {
                run_id: row.get(0)?,
                total_time: row.get(1)?,
                total_flight_time: row.get(2)?,
                total_shield_time: row.get(3)?,
                total_leg_time: row.get(4)?,
                total_body_time: row.get(5)?,
                total_pylon_time: row.get(6)?,
            })
        })
        .optional()?;

    Ok(result)
}
