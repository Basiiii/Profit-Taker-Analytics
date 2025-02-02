//! # `SquadMember` Repository  
//!  
//! This repository is responsible for interacting with the `squad_members` table in the database. It provides functionality 
//! to insert new squad members for a run and retrieve the squad members for a given run.  
//!
//! ## Key Features  
//! - Retrieve squad members for a specific run.  
//! - Insert new squad members into the database for a given run.  
//!
//! ## Example Usage  
//! ```rust
//! use crate::repositories::SquadMemberRepository;
//! use lib_profit_taker_core::SquadMember;
//! use rusqlite::Connection;
//!
//! let conn = Connection::open("path_to_db").unwrap();
//! let squad_member_repo = SquadMemberRepository::new(&conn);
//!
//! // Fetch squad members for a specific run
//! let squad_members = squad_member_repo.get_for_run(1).unwrap();
//!
//! // Insert a new squad member into the database
//! let squad_member = SquadMember { member_name: "John Doe".to_string() };
//! squad_member_repo.insert_for_run(1, &squad_member).unwrap();
//! ```  

use lib_profit_taker_core::SquadMember;
use crate::error::Result;
use rusqlite::{params, Connection};

/// A repository for interacting with the `squad_members` table in the database.
pub struct SquadMemberRepository<'a> {
    conn: &'a Connection,
}

impl<'a> SquadMemberRepository<'a> {
    /// Creates a new instance of `SquadMemberRepository` with the provided database connection.
    ///
    /// # Arguments
    /// - `conn`: A reference to an open `rusqlite::Connection`.
    ///
    /// # Returns
    /// A new instance of `SquadMemberRepository`.
    pub const fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    /// Retrieves the squad members for a specific run, ordered by member name.
    ///
    /// This method fetches all squad members recorded in the `squad_members` table for the provided `run_id`.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run for which to retrieve squad members.
    ///
    /// # Returns
    /// - `Ok(Vec<SquadMember>)`: A vector of `SquadMember` objects for the given run.
    /// - `Err`: If there was an error fetching the data.
    pub fn get_for_run(&self, run_id: i32) -> Result<Vec<SquadMember>> {
        let mut stmt = self.conn.prepare(
            "SELECT member_name FROM squad_members WHERE run_id = ? ORDER BY member_name",
        )?;

        let rows = stmt.query_map([run_id], |row| {
            Ok(SquadMember {
                member_name: row.get(0)?,
            })
        })?;

        // Collect results and convert error type
        rows.collect::<std::result::Result<Vec<_>, _>>()
            .map_err(Into::into)
    }

    /// Inserts a new squad member into the `squad_members` table for a given run.
    ///
    /// This method inserts a new `SquadMember` record into the `squad_members` table for the provided `run_id`.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run for which to insert the squad member.
    /// - `member`: A reference to the `SquadMember` object to be inserted.
    ///
    /// # Returns
    /// - `Ok(())`: If the squad member was successfully inserted.
    /// - `Err`: If there was an error during the insertion process.
    pub fn insert_for_run(&self, run_id: i64, member: &SquadMember) -> Result<()> {
        self.conn.execute(
            "INSERT INTO squad_members (run_id, member_name) VALUES (?1, ?2)",
            params![run_id, member.member_name],
        )?;
        Ok(())
    }
}
