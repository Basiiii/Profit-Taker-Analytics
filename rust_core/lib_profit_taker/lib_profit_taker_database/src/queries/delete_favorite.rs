//! # Delete Favorite Module  
//!  
//! This module provides functionality to unmark a `Run` as a favorite in the database  
//! using the `FavoriteRepository`.  
//!  
//! ## Features  
//! - Removes a `Run` from the favorites list.  
//! - Uses repository-based data access for maintainability.  
//! - Provides an easy-to-use API for external calls (e.g., from Flutter).  
//!  
//! ## Usage  
//! ```rust
//! use crate::queries::remove_favorite::unmark_as_favorite;
//! 
//! let run_id = 1; // The ID of the run to be unmarked as favorite
//! if let Err(e) = unmark_as_favorite(run_id) {
//!     eprintln!("Error removing run from favorites: {}", e);
//! }
//! ```  

use rusqlite::Connection;
use crate::{error::Result, repositories::FavoriteRepository};
use crate::connection::get_db_path;

/// Removes a `Run` from the favorites list in the database.
/// 
/// This function establishes a connection to the `SQLite` database and utilizes the
/// `FavoriteRepository` to delete the favorite entry for the provided `run_id`. 
/// It is designed to be easy to use in external applications, such as a Flutter-based app.
/// 
/// # Arguments
/// - `run_id` - The ID of the `Run` to be removed from favorites.
/// 
/// # Returns
/// - `Ok(())` if the removal was successful.
/// - `Err` if there is an error during the removal process, such as a database connection failure 
///   or if the favorite entry does not exist.
/// 
/// # Errors
/// - Returns an error if there is an issue with the database connection.
/// - Returns an error if the removal fails due to the favorite not existing.
/// 
/// # Example
/// ```rust
/// use crate::queries::remove_favorite::unmark_as_favorite;
/// 
/// let run_id = 1; // The ID of the run to be unmarked as favorite
/// if let Err(e) = unmark_as_favorite(run_id) {
///     eprintln!("Error removing run from favorites: {}", e);
/// }
/// ```
pub fn unmark_as_favorite(run_id: i32) -> Result<()> {
    // Retrieve the global database path
    let db_path = get_db_path()?;

    // Try to open the connection to the database
    let conn = Connection::open(&db_path)?;

    // Create the FavoriteRepository and use it to remove the favorite record
    let favorite_repo = FavoriteRepository::new(&conn);
    favorite_repo.remove_favorite(run_id)
}
