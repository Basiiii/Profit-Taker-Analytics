//! # Error Handling Module  
//!  
//! This module defines a custom error type for handling various errors that may  
//! occur during database operations and data processing.  
//!  
//! ## Features  
//! - Centralized error management using `thiserror::Error`.  
//! - Conversion from `rusqlite::Error` for seamless database error handling.  
//! - Custom error variants for missing data and invalid formats.  
//! - A `Result<T>` alias for convenience in returning `DataError`.  
//!  
//! ## Usage  
//! - Use `DataError::Database` for database-related errors.  
//! - Use `DataError::NotFound` when requested data is missing.  
//! - Use `DataError::InvalidData` to handle incorrect data formats.  

use thiserror::Error;

/// Represents possible errors in the database and data processing operations.
#[derive(Error, Debug)]
pub enum DataError {
    /// Represents errors originating from `SQLite` database operations.
    ///  
    /// This variant wraps `rusqlite::Error`, allowing seamless conversion  
    /// from `SQLite` errors to `DataError` using `#[from]`.  
    ///
    /// # Example
    /// ```
    /// let db_error: rusqlite::Error = some_db_function().unwrap_err();
    /// let error: DataError = db_error.into();
    /// ```
    #[error("Database error: {0}")]
    Database(#[from] rusqlite::Error),
    
    /// Represents an error when a requested run is not found.
    ///
    /// This error is used when a query expecting data returns no results.
    #[error("Run not found")]
    NotFound,
    
    /// Represents an error when the provided data format is invalid.
    ///
    /// This variant contains a string message describing the format issue.
    ///
    /// # Example
    /// ```
    /// let error = DataError::InvalidData("Missing required field".to_string());
    /// ```
    #[error("Invalid data format: {0}")]
    InvalidData(String),
}

/// A convenient alias for results that return `DataError` on failure.
///
/// This alias is used to simplify function signatures throughout the application.
///
/// # Example
/// ```
/// fn load_data() -> Result<MyStruct> {
///     // Some operation that may fail with a `DataError`
/// }
/// ```
pub type Result<T> = std::result::Result<T, DataError>;
