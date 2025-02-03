//! # Favorite Repository  
//!  
//! This repository manages interactions with the `favorites` table in the database. It provides 
//! methods to add and remove favorite runs, as well as to query if a run is marked as a favorite.
//!  
//! ## Key Features  
//! - Marks runs as favorites by inserting them into the `favorites` table.  
//! - Removes runs from favorites by deleting them from the `favorites` table.  
//! - Checks if a run is marked as a favorite.  
//!  
//! ## Example Usage  
//! ```rust  
//! use crate::repositories::FavoriteRepository;  
//! use rusqlite::Connection;  
//! 
//! let conn = Connection::open("path_to_db").unwrap();  
//! let favorite_repo = FavoriteRepository::new(&conn);  
//! 
//! // Mark a run as favorite  
//! favorite_repo.add_favorite(1).unwrap();  
//! 
//! // Check if a run is a favorite  
//! let is_fav = favorite_repo.is_favorite(1).unwrap();  
//! println!("Is run 1 a favorite? {}", is_fav);  
//! 
//! // Remove a run from favorites  
//! favorite_repo.remove_favorite(1).unwrap();  
//! ```  

use rusqlite::{params, Connection};  
use crate::error::Result;  
use chrono::Local;

/// A repository for interacting with the `favorites` table in the database.
pub struct FavoriteRepository<'a> {
    conn: &'a Connection,
}

impl<'a> FavoriteRepository<'a> {
    /// Creates a new instance of `FavoriteRepository` with the provided database connection.
    ///
    /// # Arguments
    /// - `conn`: A reference to an open `rusqlite::Connection`.
    ///
    /// # Returns
    /// A new instance of `FavoriteRepository`.
    pub const fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    /// Marks a run as favorite by inserting it into the `favorites` table with the current local timestamp.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run to be marked as favorite.
    ///
    /// # Returns
    /// - `Ok(())` if the insertion is successful.
    /// - `Err` if there's an issue during insertion (e.g., constraint violation).
    pub fn insert_favorite(&self, run_id: i32) -> Result<()> {
        let local_timestamp = Local::now().timestamp();  // Get local time as UNIX timestamp
        self.conn.execute(
            "INSERT INTO favorites (run_id, favorited_at) VALUES (?1, ?2)",
            params![run_id, local_timestamp],
        )?;
        Ok(())
    }

    /// Removes a run from favorites by deleting it from the `favorites` table.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run to be removed from favorites.
    ///
    /// # Returns
    /// - `Ok(())`: If the run was successfully removed from favorites.
    /// - `Err`: If there was an error during the deletion process.
    pub fn remove_favorite(&self, run_id: i32) -> Result<()> {
        self.conn.execute(
            "DELETE FROM favorites WHERE run_id = ?1",
            params![run_id],
        )?;
        Ok(())
    }

    /// Checks if a run is marked as a favorite.
    ///
    /// # Arguments
    /// - `run_id`: The ID of the run to check.
    ///
    /// # Returns
    /// - `Ok(true)`: If the run is marked as a favorite.
    /// - `Ok(false)`: If the run is not marked as a favorite.
    /// - `Err`: If there was an error during the query process.
    pub fn is_favorite(&self, run_id: i32) -> Result<bool> {
        let mut stmt = self.conn.prepare("SELECT 1 FROM favorites WHERE run_id = ?1")?;
        let mut rows = stmt.query(params![run_id])?;
        Ok(rows.next()?.is_some())
    }
}
