//! # Fetch Second Best Times Module  
//!  
//! This module provides functionality to retrieve the times of the 2nd best run.  
//!  
//! ## Features  
//! - Fetches the `total_time`, `total_flight_time`, `total_shield_time`, `total_leg_time`,  
//!   `total_body_time`, and `total_pylon_time` of the 2nd best run.  
//! - Uses `rusqlite` for efficient database queries.  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::fetch_second_best_times::fetch_second_best_times;
//!
//! match fetch_second_best_times() {
//!     Ok(Some(second_best_times)) => println!("2nd Best Times: {:?}", second_best_times),
//!     Ok(None) => println!("No 2nd best run found."),
//!     Err(e) => eprintln!("Error fetching 2nd best times: {}", e),
//! }
//! ```  

use crate::connection::get_db_path;
use rusqlite::{Connection, OptionalExtension, Result};

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

/// Fetches the times of the 2nd best run.
pub fn fetch_second_best_times() -> Result<Option<RunTimes>> {
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path)?;

    let mut stmt = conn.prepare(
    "SELECT id, total_time, total_flight_time, total_shield_time, total_leg_time, total_body_time, total_pylon_time
        FROM runs
        WHERE solo_run = 1 AND aborted_run = 0 AND bugged_run = 0
        AND total_time > (
            SELECT MIN(total_time) FROM runs
            WHERE solo_run = 1 AND aborted_run = 0 AND bugged_run = 0
        )
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
