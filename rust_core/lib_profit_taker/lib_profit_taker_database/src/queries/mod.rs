//! # Database Query Module  
//!  
//! This module provides various database query functions for interacting with run data  
//! stored in an `SQLite` database. It includes functions for retrieving, inserting,  
//! deleting, and checking the existence of run records.  
//!  
//! ## Features  
//! - Fetching run data by ID (`fetch_run_from_db`).  
//! - Retrieving the latest, earliest, previous, and next runs.  
//! - Checking if a run exists in the database.  
//! - Inserting and deleting run records.  
//!  
//! ## Usage  
//! - Import specific queries as needed, e.g., `fetch_run_from_db` to retrieve a run by ID.  
//! - Queries interact with the database using `rusqlite` for efficient data retrieval.  
//!  
//! ## Modules  
//! - `fetch_run_data`: Fetch a specific run from the database.  
//! - `fetch_latest_run`: Retrieve the most recent run.  
//! - `fetch_earliest_run`: Retrieve the earliest recorded run.  
//! - `fetch_previous_run`: Get the run preceding a given run.  
//! - `fetch_next_run`: Get the run following a given run.  
//! - `run_exists`: Check if a specific run exists.  
//! - `delete_run`: Remove a run from the database.  
//! - `insert_run`: Insert a new run into the database.  
//! - `latest_run`: Check if a given run is the latest run.
//! - `insert_favorite`: Insert a record into favorites table.
//! - `delete_favorite`: Removes a record from favorites table.
//! - `edit_run_name`: Edits the name of a specific run.

pub mod fetch_run_data;
pub use fetch_run_data::fetch_run_from_db;
pub mod fetch_latest_run;
pub mod fetch_earliest_run;
pub mod fetch_previous_run;
pub mod fetch_next_run;
pub mod run_exists;
pub mod delete_run;
pub mod insert_run;
pub mod latest_run;
pub mod insert_favorite;
pub mod delete_favorite;
pub mod edit_run_name;