use lib_profit_taker_database::{connection::initialize_database, queries::{
    delete_run::delete_run, fetch_earliest_run::fetch_earliest_run_id, fetch_latest_run::fetch_latest_run_id, fetch_next_run::fetch_next_run_id, fetch_previous_run::fetch_previous_run_id, fetch_run_data::fetch_run_from_db, run_exists::run_exists
}};

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn initialize_db(path: String) -> String {
    let db_path = path.as_str();

    // Try to initialize the database (either create or set the path)
    match initialize_database(db_path) {
        Ok(_) => "Database initialized successfully".to_string(),
        Err(e) => {
            // Return the error as a string for Flutter
            format!("Error initializing database: {}", e)
        }
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_run_from_db(run_id: i32) -> String {
    // Call the top-level fetch function in queries
    match fetch_run_from_db(run_id) {
        Ok(run) => {
            // Return the run data as a string (this can be serialized to JSON or similar)
            format!("{:?}", run)  // For now, use debug formatting
        }
        Err(e) => {
            // Handle the error and return it
            format!("Error fetching run: {}", e)
        }
    }
}

// Fetches the latest run ID.
///
/// This function wraps the `fetch_latest_run_id` function to make it accessible to Flutter.
/// Returns the latest run ID as a `String`.
#[flutter_rust_bridge::frb(sync)]
pub fn get_latest_run_id() -> String {
    match fetch_latest_run_id() {
        Ok(Some(run_id)) => run_id.to_string(),
        Ok(None) => "No runs found".to_string(),
        Err(e) => format!("Error fetching latest run ID: {}", e),
    }
}

/// Fetches the earliest run ID.
///
/// This function wraps the `fetch_earliest_run_id` function to make it accessible to Flutter.
/// Returns the first run ID as a `String`.
#[flutter_rust_bridge::frb(sync)]
pub fn get_earliest_run_id() -> String {
    match fetch_earliest_run_id() {
        Ok(Some(run_id)) => run_id.to_string(),
        Ok(None) => "No runs found".to_string(),
        Err(e) => format!("Error fetching first run ID: {}", e),
    }
}

/// Fetches the previous run ID relative to a given run ID.
///
/// This function wraps the `fetch_previous_run_id` function to make it accessible to Flutter.
/// Returns the previous run ID as a `String`.
#[flutter_rust_bridge::frb(sync)]
pub fn get_previous_run_id(current_run_id: i32) -> String {
    match fetch_previous_run_id(current_run_id) {
        Ok(Some(run_id)) => run_id.to_string(),
        Ok(None) => "No previous run found".to_string(),
        Err(e) => format!("Error fetching previous run ID: {}", e),
    }
}

/// Fetches the next run ID relative to a given run ID.
///
/// This function wraps the `fetch_next_run_id` function to make it accessible to Flutter.
/// Returns the next run ID as a `String`.
#[flutter_rust_bridge::frb(sync)]
pub fn get_next_run_id(current_run_id: i32) -> String {
    match fetch_next_run_id(current_run_id) {
        Ok(Some(run_id)) => run_id.to_string(),
        Ok(None) => "No next run found".to_string(),
        Err(e) => format!("Error fetching next run ID: {}", e),
    }
}

/// Checks whether a run exists with the given run ID.
///
/// This function wraps the `run_exists` function to make it accessible to Flutter.
/// Returns `true` if the run exists, `false` otherwise.
#[flutter_rust_bridge::frb(sync)]
pub fn check_run_exists(run_id: i32) -> bool {
    match run_exists(run_id) {
        Ok(exists) => exists,
        Err(_) => false, // On error, default to `false`
    }
}

/// Deletes a run by its ID.
///
/// # Arguments
/// - `run_id`: The ID of the run to delete.
/// - `db_path`: The path to the SQLite database.
///
/// # Returns
/// - `true` if the run was successfully deleted.
/// - `false` if there was an error.
#[flutter_rust_bridge::frb(sync)]
pub fn delete_run_from_db(run_id: i32) -> bool {
    match delete_run(run_id) {
        Ok(_) => true,  // Successfully deleted
        Err(_) => false, // Failed to delete
    }
}
