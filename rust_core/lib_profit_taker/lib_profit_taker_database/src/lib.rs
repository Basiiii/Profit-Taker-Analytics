//! This library provides an abstraction for interacting with the SQLite database.
//! It handles connection creation, migrations, and queries to allow other parts of the application
//! to perform database operations easily.

#![warn(clippy::nursery, clippy::pedantic)]

pub mod connection;  // Include the `connection.rs` module
pub mod schema;      // Include the schema definitions
pub mod models;      // Expose models (for use in the DB library)

// TODO: include more modules here for additional functionality like inserts, fetches, etc
