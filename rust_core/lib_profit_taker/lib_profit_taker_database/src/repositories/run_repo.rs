//! # Run Repository  
//!  
//! This repository is responsible for interacting with the `runs` table in the database, along with related data such as  
//! squad members, phases, and their respective metrics. It provides functionality to retrieve and insert `Run` records,  
//! along with their associated entities like squad members and phases. The repository pattern is used for maintainability, 
//! and it offers a clean API for interacting with these entities.
//!
//! ## Key Features  
//! - Retrieve a specific `Run` by ID, including related data (e.g., phases, squad members).  
//! - Insert a new `Run` and its related data (e.g., squad members, phases).  
//! - Provides an easy-to-use interface for external callers (e.g., Flutter app).
//!
//! ## Example Usage  
//! ```rust
//! use crate::repositories::RunRepository;
//! use rusqlite::Connection;
//!
//! let conn = Connection::open("path_to_db").unwrap();
//! let run_repo = RunRepository::new(&conn);
//!
//! // Fetch a specific run by its ID
//! let run = run_repo.get_run(1).unwrap();
//!
//! // Insert a new run into the database
//! let run = Run::new(...);  // Create a new Run instance with necessary data
//! run_repo.insert_run(&run).unwrap();
//! ```  

use lib_profit_taker_core::{Run, TotalTimes};
use crate::error::{Result, DataError};
use rusqlite::{Connection, params};
use super::{SquadMemberRepository, PhaseRepository};

/// A repository for interacting with the `runs` table in the database.
pub struct RunRepository<'a> {
    conn: &'a Connection,
}

impl<'a> RunRepository<'a> {
    /// Creates a new instance of `RunRepository` with the provided database connection.
    ///
    /// # Arguments
    /// - `conn`: A reference to an open `rusqlite::Connection`.
    ///
    /// # Returns
    /// A new instance of `RunRepository`.
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    /// Retrieves the data for a specific run, including related data like phases and squad members.
    ///
    /// This method fetches the `Run` data based on the provided `run_id`, then uses additional repositories
    /// to fetch related data such as squad members and phases.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run to retrieve.
    ///
    /// # Returns
    /// - `Ok(Run)`: The `Run` object containing the data for the run, including its associated phases and squad members.
    /// - `Err`: If there was an error fetching the data (e.g., if the run is not found).
    pub fn get_run(&self, run_id: i32) -> Result<Run> {
        // Get all data directly using the connection
        let run = self.get_run_data(self.conn, run_id)?;
        
        // Get squad members
        let squad_repo = SquadMemberRepository::new(self.conn);
        let squad_members = squad_repo.get_for_run(run_id)?;
        
        // Get phases with their details
        let phase_repo = PhaseRepository::new(self.conn);
        let phases = phase_repo.get_for_run(run_id)?;

        Ok(Run {
            run_id,
            time_stamp: run.time_stamp,
            run_name: run.run_name,
            player_name: run.player_name,
            is_bugged_run: run.is_bugged_run,
            is_aborted_run: run.is_aborted_run,
            is_solo_run: run.is_solo_run,
            total_times: run.total_times,
            phases,
            squad_members,
        })
    }

    /// Retrieves the core data for a specific run.
    ///
    /// This is a helper function to fetch the `Run` data (excluding related entities such as phases and squad members)
    /// directly from the database using a SQL query.
    ///
    /// # Arguments
    /// - `conn`: The database connection.
    /// - `run_id`: The ID of the run.
    ///
    /// # Returns
    /// - `Ok(Run)`: A `Run` object populated with the retrieved data.
    /// - `Err`: If there was an error fetching the data.
    fn get_run_data(&self, conn: &Connection, run_id: i32) -> Result<Run> {
        let mut stmt = conn.prepare(
            r#"SELECT 
                id,
                time_stamp,
                run_name,
                player_name,
                bugged_run,
                aborted_run,
                solo_run,
                total_time,
                total_flight_time,
                total_shield_time,
                total_leg_time,
                total_body_time,
                total_pylon_time
            FROM runs 
            WHERE id = ?"#,
        )?;

        let mut rows = stmt.query([run_id])?;
        let row = rows.next()?.ok_or(DataError::NotFound)?;

        Ok(Run {
            run_id: row.get(0)?,
            time_stamp: row.get(1)?,
            run_name: row.get(2)?,
            player_name: row.get(3)?,
            is_bugged_run: row.get::<_, i64>(4)? != 0,
            is_aborted_run: row.get::<_, i64>(5)? != 0,
            is_solo_run: row.get::<_, i64>(6)? != 0,
            total_times: TotalTimes {
                total_time: row.get(7)?,
                total_flight_time: row.get(8)?,
                total_shield_time: row.get(9)?,
                total_leg_time: row.get(10)?,
                total_body_time: row.get(11)?,
                total_pylon_time: row.get(12)?,
            },
            phases: Vec::new(),
            squad_members: Vec::new(),
        })
    }

    /// Inserts a new `Run` and its associated data (squad members and phases) into the database.
    ///
    /// This method performs the insertion of the `Run` data into the `runs` table, then proceeds to insert related entities,
    /// such as squad members and phases (along with their related data like leg breaks and shield changes), by calling
    /// appropriate methods on other repositories.
    ///
    /// # Arguments
    /// - `run`: A reference to a `Run` object containing the data to be inserted.
    ///
    /// # Returns
    /// - `Ok(())`: If the insertion was successful.
    /// - `Err`: If there was an error during the insertion process.
    pub fn insert_run(&self, run: &Run) -> Result<()> {
        // Insert the Run into the runs table
        self.conn.execute(
            "INSERT INTO runs (time_stamp, run_name, player_name, bugged_run, aborted_run, solo_run, 
                               total_time, total_flight_time, total_shield_time, total_leg_time, 
                               total_body_time, total_pylon_time) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12)",
            params![
                run.time_stamp,
                run.run_name,
                run.player_name,
                run.is_bugged_run,
                run.is_aborted_run,
                run.is_solo_run,
                run.total_times.total_time,
                run.total_times.total_flight_time,
                run.total_times.total_shield_time,
                run.total_times.total_leg_time,
                run.total_times.total_body_time,
                run.total_times.total_pylon_time
            ]
        )?;
    
        // Get the last inserted run id
        let run_id = self.conn.last_insert_rowid();
    
        // Insert Squad Members into the squad_members table
        let squad_repo = SquadMemberRepository::new(self.conn);
        for member in &run.squad_members {
            squad_repo.insert_for_run(run_id, member)?;
        }
    
        // Insert Phases into the phases table and related data (leg breaks, shield changes)
        let phase_repo = PhaseRepository::new(self.conn);
        for phase in &run.phases {
            phase_repo.insert_for_run(run_id, phase)?;
        }
    
        Ok(())
    }    
}
