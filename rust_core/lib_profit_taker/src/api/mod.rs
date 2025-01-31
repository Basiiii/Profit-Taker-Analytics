use lib_profit_taker_database::{connection::create_database, queries::fetch_run_from_db};

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn create_db(path: String) -> String {
    let db_path = path.as_str();

    // Try to create the database and run migrations
    match create_database(db_path) {
        Ok(_) => "Database created successfully".to_string(),
        Err(e) => {
            // Return the error as a string for Flutter
            format!("Error creating database: {}", e)
        }
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_run_from_db(run_id: i32, db_path: String) -> String {
    // Call the top-level fetch function in queries
    match fetch_run_from_db(&db_path, run_id) {
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
