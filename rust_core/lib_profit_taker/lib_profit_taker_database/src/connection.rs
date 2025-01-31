//! # `SQLite` Database Management Module
//!
//! This module provides functionality for managing an `SQLite` database,
//! including setting the database path, creating the database file, and initializing the schema.
//!
//! ## Features
//! - **Global Database Path Management**: Ensures a consistent database path across operations.
//! - **Database Initialization**: Creates the database file if it does not exist and sets up the schema.
//! - **Schema Setup**: Executes predefined SQL commands to create necessary tables and insert default data.
//!
//! ## Usage
//! - Use `set_db_path` to define a global database path.
//! - Use `initialize_database` to create the database if it does not exist.
//! - Use `create_database` to explicitly create a new database and initialize its schema.
//! - Use `initialize_schema` to set up the required tables and default values.
//!
//! This module relies on `rusqlite` for database operations and `once_cell` for global state management.

use std::sync::Mutex;
use once_cell::sync::Lazy;
use rusqlite::{Connection, Result};
use std::fs;
use std::path::Path;
use crate::schema::SCHEMA_SQL;

/// A globally shared, thread-safe mutable database path.
/// 
/// This static variable stores the path to the `SQLite` database and ensures that it can be accessed 
/// and modified safely across multiple threads using a `Mutex`. The `Lazy` initialization 
/// ensures that the mutex is only created when it is first accessed.
///
/// - **Type**: `Lazy<Mutex<Option<String>>>`
/// - **Usage**: Used to store and retrieve the global database path.
/// - **Thread Safety**: Wrapped in a `Mutex` to ensure safe concurrent access.
///
/// ## Notes
/// - The database path can only be set once using `set_db_path()`. 
/// - Once set, it can be retrieved using `get_db_path()`.  
/// - If not set, `get_db_path()` will return an error.
static DB_PATH: Lazy<Mutex<Option<String>>> = Lazy::new(|| Mutex::new(None));

/// Sets the global database path.
///
/// This function initializes the global database path, which will be used for all database-related operations.
///
/// # Arguments
/// - `path`: The file path to the `SQLite` database.
///
/// # Returns
/// - `Ok(())` if the path was successfully set.
/// - An `Err` if the path is already set.
/// 
/// # Panics
/// This function will panic if the lock on `DB_PATH` is poisoned, meaning another thread panicked while holding the lock.
pub fn set_db_path(path: &str) -> Result<()> {
    let mut db_path = DB_PATH.lock().unwrap();
    if db_path.is_some() {
        Err(rusqlite::Error::ToSqlConversionFailure(Box::new(std::io::Error::new(
            std::io::ErrorKind::AlreadyExists,
            "Database path is already set.",
        ))))
    } else {
        *db_path = Some(path.to_string());
        Ok(())
    }
}

/// Retrieves the global database path.
///
/// # Returns
/// - `Ok(String)` if the path is set.
/// - An `Err` if the path is not set.
pub fn get_db_path() -> Result<String> {
    let db_path = DB_PATH.lock().unwrap();
    if let Some(path) = &*db_path {
        Ok(path.clone())
    } else {
        Err(rusqlite::Error::ToSqlConversionFailure(Box::new(std::io::Error::new(
            std::io::ErrorKind::NotFound,
            "Database path is not set.",
        ))))
    }
}

/// Initializes the database by checking if the database file exists.
/// If it exists, just sets the database path. If not, creates a new database.
pub fn initialize_database(path: &str) -> Result<()> {
    // Check if the database file already exists
    if Path::new(path).exists() {
        // If the database exists, just set the path
        set_db_path(path)?;
    } else {
        // If the database doesn't exist, create it
        create_database(path)?;
    }

    Ok(())
}

/// Creates an `SQLite` database file at the given path if it does not exist.
/// Ensures the directory structure is created before attempting to create the database.
/// 
/// # Arguments
/// * `path` - The file path where the `SQLite` database should be created.
/// 
/// # Returns
/// * `Result<()>` - Returns `Ok(())` if the database file is successfully created or already exists.
/// If an error occurs during directory creation or database initialization, it is returned.
pub fn create_database(path: &str) -> Result<()> {
    // Set the global database path
    set_db_path(path)?;

    // Ensure the directory exists
    if let Some(parent) = Path::new(path).parent() {
        fs::create_dir_all(parent).map_err(|e| rusqlite::Error::ToSqlConversionFailure(Box::new(e)))?;
    }

    // Create and initialize the database
    let conn = Connection::open(path)?;
    initialize_schema(&conn)?;
    
    Ok(())
}

/// Initializes the `SQLite` database schema by executing SQL statements from the constant.
///
/// This function runs the schema creation queries stored in `SCHEMA_SQL` to set up the required tables and default values.
/// 
/// # Arguments
/// * `conn` - A reference to the active `SQLite` database connection.
/// 
/// # Returns
/// * `Result<()>` - Returns `Ok(())` if the schema is successfully created, otherwise returns an error.
pub fn initialize_schema(conn: &Connection) -> Result<()> {
    conn.execute_batch(SCHEMA_SQL)?; // Execute the schema from the constant

    Ok(())
}
