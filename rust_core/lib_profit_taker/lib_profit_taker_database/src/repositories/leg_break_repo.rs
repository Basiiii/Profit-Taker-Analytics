//! # `LegBreakRepository` Module  
//!  
//! This module provides functionality for interacting with the `leg_breaks` table in the `SQLite` database.  
//! It contains methods for retrieving and inserting `LegBreak` records, associated with a specific `run_id` and `phase_number`.  
//! The repository uses the `rusqlite` crate to handle SQL queries and transactions.
//!  
//! ## Features  
//! - Fetches `LegBreak` records for a specific phase of a run.  
//! - Inserts new `LegBreak` records into the database.  
//! - Translates `leg_position` string values into strongly typed `LegPosition` enum values for better safety and clarity.
//!
//! ## Usage  
//! ```rust
//! use crate::repositories::LegBreakRepository;
//! use lib_profit_taker_core::{LegBreak, LegPosition};
//! use rusqlite::Connection;
//!
//! let conn = Connection::open("path_to_db").unwrap();
//! let repo = LegBreakRepository::new(&conn);
//!
//! // Fetch leg breaks for a specific phase
//! let leg_breaks = repo.get_for_phase(1, 2).unwrap();
//! for leg_break in leg_breaks {
//!     println!("{:?}", leg_break);
//! }
//!
//! // Insert a leg break into a specific phase
//! let new_leg_break = LegBreak {
//!     leg_break_time: 30.5,
//!     leg_position: LegPosition::FrontLeft,
//!     leg_order: 1,
//! };
//! repo.insert_for_phase(1, 2, &new_leg_break).unwrap();
//! ```  

use lib_profit_taker_core::{LegBreak, LegPosition};
use crate::error::{Result, DataError};
use rusqlite::{params, Connection};

/// A repository for interacting with the `leg_breaks` table in the database.
///
/// The `LegBreakRepository` provides methods to fetch and insert `LegBreak` data
/// related to specific run IDs and phase numbers. This allows efficient querying
/// and manipulation of leg break records in the database.
pub struct LegBreakRepository<'a> {
    conn: &'a Connection,
}

impl<'a> LegBreakRepository<'a> {
    /// Constructs a new `LegBreakRepository` instance.
    ///
    /// # Arguments
    /// * `conn` - A reference to the `Connection` to the `SQLite` database.
    ///
    /// # Returns
    /// A new `LegBreakRepository` instance.
    pub const fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    /// Retrieves all `LegBreak` records for a specific run and phase.
    ///
    /// This function queries the database to return all `LegBreak` records
    /// for a specified `run_id` and `phase_number`, ordered by `break_order`.
    ///
    /// # Arguments
    /// * `run_id` - The ID of the run for which to fetch leg break records.
    /// * `phase_number` - The phase number within the run.
    ///
    /// # Returns
    /// A `Result<Vec<LegBreak>>` containing a vector of `LegBreak` objects
    /// if successful, or an error if the query fails.
    ///
    /// # Errors
    /// Will return a `DataError::InvalidData` error if the leg position is invalid.
    pub fn get_for_phase(&self, run_id: i32, phase_number: i32) -> Result<Vec<LegBreak>> {
        let mut stmt = self.conn.prepare(
            r"SELECT 
                break_time,
                break_order,
                lp.name AS leg_position
            FROM leg_breaks lb
            JOIN leg_position lp ON lb.leg_position_id = lp.id
            WHERE run_id = ? AND phase_number = ?
            ORDER BY break_order",
        )?;

        let breaks = stmt.query_map([run_id, phase_number], |row| {
            let break_time: f64 = row.get(0)?;
            let position_str: String = row.get(2)?;
            let leg_position = match position_str.as_str() {
                "FL" => LegPosition::FrontLeft,
                "FR" => LegPosition::FrontRight,
                "BL" => LegPosition::BackLeft,
                "BR" => LegPosition::BackRight,
                _ => return Err(rusqlite::Error::FromSqlConversionFailure(
                    2,
                    rusqlite::types::Type::Text,
                    Box::new(DataError::InvalidData(format!(
                        "Invalid leg position: {position_str}"
                    ))),
                )),
            };

            Ok(LegBreak {
                leg_break_time: break_time,
                leg_position,
                leg_order: row.get(1)?,
            })
        })?;

        breaks.collect::<std::result::Result<Vec<_>, _>>()
            .map_err(|e| DataError::InvalidData(format!(
                "Invalid leg break data: {e}"
            )))
    }

    /// Inserts a `LegBreak` record for a specified phase and run into the database.
    ///
    /// This function inserts a `LegBreak` into the `leg_breaks` table for a specific
    /// `run_id` and `phase_number`. It also handles the conversion of the `leg_position`
    /// enum into a corresponding string value (`FL`, `FR`, `BL`, or `BR`).
    ///
    /// # Arguments
    /// * `run_id` - The ID of the run for which to insert the leg break.
    /// * `phase_number` - The phase number within the run for which the leg break is being inserted.
    /// * `leg_break` - A reference to the `LegBreak` object to be inserted.
    ///
    /// # Returns
    /// A `Result` indicating whether the insertion was successful or if there was an error.
    pub fn insert_for_phase(&self, run_id: i64, phase_number: i32, leg_break: &LegBreak) -> Result<()> {
        // Insert leg break into the leg_breaks table
        self.conn.execute(
            r"INSERT INTO leg_breaks (run_id, phase_number, break_order, break_time, leg_position_id)
            VALUES (?1, ?2, ?3, ?4, (SELECT id FROM leg_position WHERE name = ?5))",
            params![
                run_id,
                phase_number,
                leg_break.leg_order,
                leg_break.leg_break_time,
                match leg_break.leg_position {
                    LegPosition::FrontLeft => "FL",
                    LegPosition::FrontRight => "FR",
                    LegPosition::BackLeft => "BL",
                    LegPosition::BackRight => "BR",
                }
            ]
        )?;

        Ok(())
    }
}
