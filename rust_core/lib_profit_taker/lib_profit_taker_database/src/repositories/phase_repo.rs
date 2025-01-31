//! # Phase Repository  
//!  
//! This repository is responsible for interacting with the `phases` table in the database, as well as managing the  
//! related `shield_changes` and `leg_breaks` data. It provides methods to retrieve and insert phases, including  
//! their associated data such as shield changes and leg breaks, using repository-based interactions for maintainability.
//!  
//! ## Key Features  
//! - Retrieves phases associated with a specific run.  
//! - Handles the insertion of phases and their related entities (e.g., shield changes, leg breaks).  
//! - Provides easy-to-use methods for external callers (e.g., from the Flutter app).
//!
//! ## Example Usage  
//! ```rust
//! use crate::repositories::{PhaseRepository, ShieldChangeRepository, LegBreakRepository};
//! use rusqlite::Connection;
//!
//! let conn = Connection::open("path_to_db").unwrap();
//! let phase_repo = PhaseRepository::new(&conn);
//!
//! // Fetch phases for a specific run
//! let phases = phase_repo.get_for_run(1).unwrap();
//!
//! // Insert a new phase into the database
//! let phase = Phase::new(...);  // Fill in required data
//! phase_repo.insert_for_run(1, &phase).unwrap();
//! ```  

use lib_profit_taker_core::{Phase, ShieldChange, LegBreak};
use crate::error::Result;
use rusqlite::{params, Connection, Row};
use super::{ShieldChangeRepository, LegBreakRepository};


/// A repository for interacting with the `phases` table in the database.
pub struct PhaseRepository<'a> {
    conn: &'a Connection,
}

impl<'a> PhaseRepository<'a> {
    /// Creates a new instance of `PhaseRepository` with the provided database connection.
    ///
    /// # Arguments
    /// - `conn`: A reference to an open `rusqlite::Connection`.
    ///
    /// # Returns
    /// A new instance of `PhaseRepository`.
    pub const fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    /// Retrieves all phases associated with a specific run.
    ///
    /// This method fetches the phases for a given `run_id` and also loads related data, including `shield_changes` 
    /// and `leg_breaks`, by invoking the appropriate methods to gather the additional data.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run whose phases are to be retrieved.
    ///
    /// # Returns
    /// - `Ok(Vec<Phase>)`: A vector of `Phase` objects representing the phases of the specified run.
    /// - `Err`: If there is an error fetching the phases or related data.
    pub fn get_for_run(&self, run_id: i32) -> Result<Vec<Phase>> {
        let mut stmt = self.conn.prepare(
            r"SELECT 
                phase_number,
                phase_time,
                shield_time,
                leg_time,
                body_kill_time,
                pylon_time
            FROM phases 
            WHERE run_id = ? 
            ORDER BY phase_number",
        )?;

        let phases = stmt
            .query_map([run_id], |row| Ok(self.row_to_phase(row)))?
            .collect::<std::result::Result<Vec<_>, _>>()?;

        // Load related data for each phase
        phases
            .into_iter()
            .map(|mut phase| {
                phase.shield_changes = self.get_shield_changes(run_id, phase.phase_number)?;
                phase.leg_breaks = self.get_leg_breaks(run_id, phase.phase_number)?;
                Ok(phase)
            })
            .collect()
    }

    /// Inserts a new phase into the database, along with its associated `shield_changes` and `leg_breaks`.
    ///
    /// This method performs an insert for the phase itself and delegates the insertion of related data to 
    /// the appropriate repositories (`ShieldChangeRepository` and `LegBreakRepository`).
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run to which the phase belongs.
    /// - `phase`: The `Phase` object containing data to be inserted.
    ///
    /// # Returns
    /// - `Ok(())`: If the phase and related data were successfully inserted.
    /// - `Err`: If there was an error during the insertion process.
    pub fn insert_for_run(&self, run_id: i64, phase: &Phase) -> Result<()> {
        // Insert phase into the phases table
        self.conn.execute(
            r"INSERT INTO phases (run_id, phase_number, phase_time, shield_time, leg_time, body_kill_time, pylon_time)
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            params![
                run_id,
                phase.phase_number,
                phase.total_time,
                phase.total_shield_time,
                phase.total_leg_time,
                phase.total_body_kill_time,
                phase.total_pylon_time,
            ]
        )?;
    
        // Insert leg breaks related to this phase
        let leg_break_repo = LegBreakRepository::new(self.conn);
        for leg_break in &phase.leg_breaks {
            leg_break_repo.insert_for_phase(run_id, phase.phase_number, leg_break)?;
        }
    
        // Insert shield changes related to this phase
        let shield_change_repo = ShieldChangeRepository::new(self.conn);
        for shield_change in &phase.shield_changes {
            shield_change_repo.insert_for_phase(run_id, phase.phase_number, shield_change)?;
        }
    
        Ok(())
    }    

    /// Converts a `rusqlite::Row` into a `Phase` struct.
    ///
    /// This method is used internally to map the result of a query row into a `Phase` object.
    ///
    /// # Arguments
    /// - `row`: The row from the query result that needs to be mapped into a `Phase`.
    ///
    /// # Returns
    /// A `Phase` object populated with data from the row.
    fn row_to_phase(&self, row: &Row) -> Phase {
        Phase {
            phase_number: row.get(0).unwrap(),
            total_time: row.get::<_, Option<f64>>(1).unwrap().unwrap_or(0.0),
            total_shield_time: row.get::<_, Option<f64>>(2).unwrap().unwrap_or(0.0),
            total_leg_time: row.get::<_, Option<f64>>(3).unwrap().unwrap_or(0.0),
            total_body_kill_time: row.get::<_, Option<f64>>(4).unwrap().unwrap_or(0.0),
            total_pylon_time: row.get::<_, Option<f64>>(5).unwrap().unwrap_or(0.0),
            shield_changes: Vec::new(),
            leg_breaks: Vec::new(),
        }
    }

    /// Retrieves the shield changes for a given run and phase.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run.
    /// - `phase_number`: The number of the phase.
    ///
    /// # Returns
    /// - `Ok(Vec<ShieldChange>)`: A vector of `ShieldChange` objects related to the phase.
    /// - `Err`: If there was an error retrieving the shield changes.
    fn get_shield_changes(&self, run_id: i32, phase_number: i32) -> Result<Vec<ShieldChange>> {
        ShieldChangeRepository::new(self.conn)
            .get_for_phase(run_id, phase_number)
    }

    /// Retrieves the leg breaks for a given run and phase.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run.
    /// - `phase_number`: The number of the phase.
    ///
    /// # Returns
    /// - `Ok(Vec<LegBreak>)`: A vector of `LegBreak` objects related to the phase.
    /// - `Err`: If there was an error retrieving the leg breaks.
    fn get_leg_breaks(&self, run_id: i32, phase_number: i32) -> Result<Vec<LegBreak>> {
        LegBreakRepository::new(self.conn)
            .get_for_phase(run_id, phase_number)
    }
}
