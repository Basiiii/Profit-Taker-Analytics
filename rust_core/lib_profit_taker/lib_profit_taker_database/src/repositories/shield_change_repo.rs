//! # `ShieldChange` Repository  
//!  
//! This repository is responsible for interacting with the `shield_changes` table in the database, providing functionality 
//! to retrieve and insert shield change data. It also handles the mapping of `status_effect_id` to the corresponding 
//! `StatusEffect` enum. This repository makes it easy to manage shield changes during phases of a run and persist them to 
//! the database, as well as to retrieve them when needed.
//!
//! ## Key Features  
//! - Retrieve shield changes for a specific run and phase.  
//! - Insert new shield changes into the database for a specific phase.  
//! - Automatically map status effect IDs to their corresponding `StatusEffect` enum values.
//!
//! ## Example Usage  
//! ```rust
//! use crate::repositories::ShieldChangeRepository;
//! use rusqlite::Connection;
//!
//! let conn = Connection::open("path_to_db").unwrap();
//! let shield_change_repo = ShieldChangeRepository::new(&conn);
//!
//! // Fetch shield changes for a specific run and phase
//! let shield_changes = shield_change_repo.get_for_phase(1, 2).unwrap();
//!
//! // Insert a new shield change into the database
//! let shield_change = ShieldChange { shield_time: 30.0, status_effect: StatusEffect::Impact };
//! shield_change_repo.insert_for_phase(1, 2, &shield_change).unwrap();
//! ```  

use lib_profit_taker_core::{ShieldChange, StatusEffect};
use crate::error::{Result, DataError};
use rusqlite::{params, Connection};

/// A repository for interacting with the `shield_changes` table in the database.
pub struct ShieldChangeRepository<'a> {
    conn: &'a Connection,
}

impl<'a> ShieldChangeRepository<'a> {
    /// Creates a new instance of `ShieldChangeRepository` with the provided database connection.
    ///
    /// # Arguments
    /// - `conn`: A reference to an open `rusqlite::Connection`.
    ///
    /// # Returns
    /// A new instance of `ShieldChangeRepository`.
    pub const fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    /// Retrieves the shield changes for a specific run and phase, including the status effect.
    ///
    /// This method fetches all shield changes recorded in the `shield_changes` table for the provided `run_id` and 
    /// `phase_number`, mapping each record's `status_effect_id` to the corresponding `StatusEffect` enum. It returns 
    /// a vector of `ShieldChange` objects.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run for which to retrieve shield changes.
    /// - `phase_number`: The phase number within the run for which to retrieve shield changes.
    ///
    /// # Returns
    /// - `Ok(Vec<ShieldChange>)`: A vector of `ShieldChange` objects for the given run and phase.
    /// - `Err`: If there was an error fetching the data (e.g., invalid status effect ID).
    pub fn get_for_phase(&self, run_id: i32, phase_number: i32) -> Result<Vec<ShieldChange>> {
        let mut stmt = self.conn.prepare(
            r"SELECT 
                shield_time,
                status_effect_id
            FROM shield_changes
            WHERE run_id = ? AND phase_number = ?
            ORDER BY shield_time",
        )?;

        let changes = stmt.query_map([run_id, phase_number], |row| {
            let effect_id: i32 = row.get(1)?;
            let status_effect = match effect_id {
                1 => StatusEffect::Impact,
                2 => StatusEffect::Puncture,
                3 => StatusEffect::Slash,
                4 => StatusEffect::Heat,
                5 => StatusEffect::Cold,
                6 => StatusEffect::Electric,
                7 => StatusEffect::Toxin,
                8 => StatusEffect::Blast,
                9 => StatusEffect::Radiation,
                10 => StatusEffect::Gas,
                11 => StatusEffect::Magnetic,
                12 => StatusEffect::Viral,
                13 => StatusEffect::Corrosive,
                _ => return Err(rusqlite::Error::FromSqlConversionFailure(
                    1,
                    rusqlite::types::Type::Integer,
                    Box::new(DataError::InvalidData(format!(
                        "Invalid status effect ID: {effect_id}"
                    ))),
                )),
            };

            Ok(ShieldChange {
                shield_time: row.get(0)?,
                status_effect,
            })
        })?;

        changes.collect::<std::result::Result<Vec<_>, _>>()
            .map_err(|e| DataError::InvalidData(format!(
                "Invalid shield change data: {e}"
            )))
    }
    
    /// Inserts a shield change into the `shield_changes` table for a specific phase.
    ///
    /// This method inserts a new `ShieldChange` record into the `shield_changes` table for the given `run_id` and 
    /// `phase_number`. It maps the `StatusEffect` enum to the corresponding `status_effect_id` when inserting the record.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run for which to insert the shield change.
    /// - `phase_number`: The phase number within the run for which to insert the shield change.
    /// - `shield_change`: A reference to the `ShieldChange` object to be inserted.
    ///
    /// # Returns
    /// - `Ok(())`: If the shield change was successfully inserted.
    /// - `Err`: If there was an error during the insertion process.
    pub fn insert_for_phase(&self, run_id: i64, phase_number: i32, shield_change: &ShieldChange) -> Result<()> {
        // Insert shield change into the shield_changes table
        self.conn.execute(
            r"INSERT INTO shield_changes (run_id, phase_number, shield_time, status_effect_id)
            VALUES (?1, ?2, ?3, ?4)",
            params![
                run_id,
                phase_number,
                shield_change.shield_time,
                match shield_change.status_effect {
                    StatusEffect::Impact => 1,
                    StatusEffect::Puncture => 2,
                    StatusEffect::Slash => 3,
                    StatusEffect::Heat => 4,
                    StatusEffect::Cold => 5,
                    StatusEffect::Electric => 6,
                    StatusEffect::Toxin => 7,
                    StatusEffect::Blast => 8,
                    StatusEffect::Radiation => 9,
                    StatusEffect::Gas => 10,
                    StatusEffect::Magnetic => 11,
                    StatusEffect::Viral => 12,
                    StatusEffect::Corrosive => 13,
                    StatusEffect::NoShield => 14,
                }
            ]
        )?;

        Ok(())
    }
}
