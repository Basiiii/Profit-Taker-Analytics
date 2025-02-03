//! # Check Favorite Status Module  
//!  
//! This module provides functionality to check if a `Run` is marked as a favorite
//! in the database using the `FavoriteRepository`.  
//!  
//! ## Features  
//! - Checks if a `Run` is a favorite using repository-based data access.  
//! - Uses SQLite database connection management.  
//! - Provides an easy-to-use API for external calls (e.g., from Flutter).  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::check_favorite_status::is_run_favorite;
//! 
//! let run_id = 1; // The ID of the run to check
//! match is_run_favorite(run_id) {
//!     Ok(is_favorite) => println!("Is run {} a favorite? {}", run_id, is_favorite),
//!     Err(e) => eprintln!("Error checking favorite status: {}", e),
//! }
//! ```  

use rusqlite::Connection;
use crate::{error::Result, repositories::FavoriteRepository};
use crate::connection::get_db_path;

/// Checks if a `Run` is marked as a favorite in the database.
/// 
/// This function establishes a connection to the `SQLite` database and utilizes the
/// `FavoriteRepository` to check if the given `run_id` exists in the `favorites` table.
/// 
/// # Arguments
/// - `run_id` - The ID of the `Run` to check.
/// 
/// # Returns
/// - `Ok(true)` if the run is marked as a favorite.
/// - `Ok(false)` if the run is not a favorite.
/// - `Err` if there is an error during the database query process.
/// 
/// # Errors
/// - Returns an error if there is an issue with the database connection.
/// - Returns an error if the query fails.
/// 
/// # Example
/// ```rust
/// use crate::queries::check_favorite_status::is_run_favorite;
/// 
/// let run_id = 1; // The ID of the run to check
/// match is_run_favorite(run_id) {
///     Ok(is_favorite) => println!("Is run {} a favorite? {}", run_id, is_favorite),
///     Err(e) => eprintln!("Error checking favorite status: {}", e),
/// }
/// ```
pub fn is_run_favorite(run_id: i32) -> Result<bool> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Try to open the connection to the database
    let conn = Connection::open(&db_path)?;

    // Create the FavoriteRepository and use it to check if the run is a favorite
    let favorite_repo = FavoriteRepository::new(&conn);
    favorite_repo.is_favorite(run_id)
}
