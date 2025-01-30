use lib_profit_taker_database::create_database;
use std::fs;

#[deprecated]
#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

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
