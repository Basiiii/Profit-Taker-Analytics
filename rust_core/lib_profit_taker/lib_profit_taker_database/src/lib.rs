//! This library will take responsibility for database operations.
//!
//! Perhaps to a level of abstraction that consumers won't need to take Diesel as a direct
//! dependency.

#![warn(clippy::nursery, clippy::pedantic)]

// src/lib.rs
use diesel::prelude::*;
use diesel::sqlite::SqliteConnection;
use diesel_migrations::{embed_migrations, EmbeddedMigrations, MigrationHarness};
use thiserror::Error;

const MIGRATIONS: EmbeddedMigrations = embed_migrations!("migrations");

#[derive(Debug, Error)]
pub enum DatabaseError {
    #[error("Connection error: {0}")]
    ConnectionError(#[from] diesel::ConnectionError),
    
    #[error("Migration error: {0}")]
    MigrationError(#[from] Box<dyn std::error::Error + Send + Sync>),
    
    #[error("Query error: {0}")]
    QueryError(#[from] diesel::result::Error),
}

/// Creates the SQLite database at the specified path
pub fn create_database(path: &str) -> Result<(), DatabaseError> {
    // Format the database URL with the provided path
    let database_url = format!("sqlite://{}", path);

    // Establish the connection to the SQLite database
    let mut connection = SqliteConnection::establish(&database_url)
        .map_err(|e| DatabaseError::ConnectionError(e.into()))?;

    // Run pending migrations (if any)
    connection
        .run_pending_migrations(MIGRATIONS)
        .map_err(|e| DatabaseError::MigrationError(e.into()))?;

    // The database file will be created automatically by SQLite if it doesn't exist
    Ok(())
}
