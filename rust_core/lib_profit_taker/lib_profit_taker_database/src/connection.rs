//! This module provides functions for interacting with an SQLite database.
//! It handles the creation of the database file and the initialization of the database schema.
//! 
//! The `create_database` function ensures that the database file exists at the given path,
//! creating the necessary directory structure if needed. It then opens a connection to the database
//! and initializes the schema by executing the SQL statements stored in `SCHEMA_SQL`.
//!
//! The `initialize_schema` function is responsible for executing the SQL schema commands to set
//! up the database tables and insert any default data required for the application to function correctly.

use rusqlite::{Connection, Result};
use std::fs;
use std::path::Path;
use crate::schema::SCHEMA_SQL;

/// Creates an SQLite database file at the given path if it does not exist.
/// Ensures the directory structure is created before attempting to create the database.
/// 
/// # Arguments
/// * `path` - The file path where the SQLite database should be created.
/// 
/// # Returns
/// * `Result<()>` - Returns `Ok(())` if the database file is successfully created or already exists.
/// If an error occurs during directory creation or database initialization, it is returned.
pub fn create_database(path: &str) -> Result<()> {
    // Ensure the directory exists
    if let Some(parent) = Path::new(path).parent() {
        fs::create_dir_all(parent).map_err(|e| rusqlite::Error::ToSqlConversionFailure(Box::new(e)))?;
    }

    // Create and initialize the database
    let conn = Connection::open(path)?;
    initialize_schema(&conn)?;
    
    Ok(())
}

/// Initializes the SQLite database schema by executing SQL statements from the constant.
///
/// This function runs the schema creation queries stored in `SCHEMA_SQL` to set up the required tables and default values.
/// 
/// # Arguments
/// * `conn` - A reference to the active SQLite database connection.
/// 
/// # Returns
/// * `Result<()>` - Returns `Ok(())` if the schema is successfully created, otherwise returns an error.
pub fn initialize_schema(conn: &Connection) -> Result<()> {
    conn.execute_batch(SCHEMA_SQL)?; // Execute the schema from the constant

    Ok(())
}
