//! # Insert Favorite Module  
//!  
//! This module provides functionality to mark a `Run` as a favorite in the database  
//! using the `FavoriteRepository`.  
//!  
//! ## Features  
//! - Marks a `Run` as a favorite with a local timestamp.  
//! - Uses repository-based data access for maintainability.  
//! - Provides an easy-to-use API for external calls (e.g., from Flutter).  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::insert_favorite::mark_as_favorite;
//! 
//! let run_id = 1; // The ID of the run to be marked as favorite
//! if let Err(e) = mark_as_favorite(run_id) {
//!     eprintln!("Error marking run as favorite: {}", e);
//! }
//! ```  

use rusqlite::Connection;
use crate::{error::Result, repositories::FavoriteRepository};
use crate::connection::get_db_path;

/// Marks a `Run` as a favorite in the database.
/// 
/// This function establishes a connection to the `SQLite` database and utilizes the
/// `FavoriteRepository` to insert the provided `run_id` along with the current local timestamp. 
/// It is designed to be easy to use in external applications, such as a Flutter-based app.
/// 
/// # Arguments
/// - `run_id` - The ID of the `Run` to be marked as favorite.
/// 
/// # Returns
/// - `Ok(())` if the insertion was successful.
/// - `Err` if there is an error during the insertion process, such as a database connection failure 
///   or any issues with the data format.
/// 
/// # Errors
/// - Returns an error if there is an issue with the database connection.
/// - Returns an error if the insertion fails due to a constraint violation or other issues.
/// 
/// # Example
/// ```rust
/// use crate::queries::insert_favorite::mark_as_favorite;
/// 
/// let run_id = 1; // The ID of the run to be marked as favorite
/// if let Err(e) = mark_as_favorite(run_id) {
///     eprintln!("Error marking run as favorite: {}", e);
/// }
/// ```
pub fn mark_as_favorite(run_id: i32) -> Result<()> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Try to open the connection to the database
    let conn = Connection::open(&db_path)?;

    // Create the FavoriteRepository and use it to insert the favorite record
    let favorite_repo = FavoriteRepository::new(&conn);
    favorite_repo.insert_favorite(run_id)
}
