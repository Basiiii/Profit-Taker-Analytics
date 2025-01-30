//! This module provides functions for establishing and managing database connections.
//! 
//! It handles creating connections to an SQLite database and can be used by other parts
//! of the application to interact with the database. The `create_database` function
//! ensures that the database exists at the provided path and applies any necessary migrations.

use diesel::prelude::*;
use diesel::sqlite::SqliteConnection;
use diesel_migrations::{embed_migrations, EmbeddedMigrations, MigrationHarness};
use thiserror::Error;
use std::path::Path;

/// The embedded migrations, allowing us to run migrations automatically if needed.
const MIGRATIONS: EmbeddedMigrations = embed_migrations!("migrations");

/// This enum is used for handling various errors that can occur in the database operations.
/// It wraps common errors that might happen during the connection setup, migrations, or queries.
#[derive(Debug, Error)]
pub enum DatabaseError {
    /// Error when connecting to the SQLite database.
    #[error("Connection error: {0}")]
    ConnectionError(#[from] diesel::ConnectionError),
    
    /// Error during the database migrations.
    #[error("Migration error: {0}")]
    MigrationError(#[from] Box<dyn std::error::Error + Send + Sync>),
    
    /// Error that occurs while executing a database query.
    #[error("Query error: {0}")]
    QueryError(#[from] diesel::result::Error),
}

/// Establishes a connection to the SQLite database at the provided path.
/// 
/// This function will create the SQLite database if it doesn't already exist. It will
/// also run any pending migrations that need to be applied. If an error occurs, it is 
/// returned wrapped in the `DatabaseError` enum.
/// 
/// # Arguments
/// 
/// * `path` - The path to the SQLite database. This should be a valid file path.
/// 
/// # Returns
/// 
/// * `Result<(), DatabaseError>` - Returns `Ok(())` if the connection is successful, or 
///   an error if the connection or migration fails.
pub fn create_database(path: &str) -> Result<(), DatabaseError> {
    // Ensure the path is a valid file path
    if !Path::new(path).exists() {
        // If the path doesn't exist, SQLite will automatically create it
        println!("Database file does not exist, will create at: {}", path);
    }

    // Format the database URL for SQLite
    let database_url = format!("sqlite://{}", path);

    // Attempt to establish a connection to the SQLite database
    let mut connection = SqliteConnection::establish(&database_url)
        .map_err(|e| DatabaseError::ConnectionError(e.into()))?;

    // Run any pending migrations that need to be applied
    connection
        .run_pending_migrations(MIGRATIONS)
        .map_err(|e| DatabaseError::MigrationError(e.into()))?;

    // Return Ok if the connection is successfully established and migrations are applied
    Ok(())
}

