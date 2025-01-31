use lib_profit_taker_core::Run;
use lib_profit_taker_database::{connection::create_database, queries::fetch_run_from_db};


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

// #[flutter_rust_bridge::frb(sync)]
// pub fn get_run_from_db(run_id: i32, db_path: String) -> String {
//     // Call the top-level fetch function in queries
//     match fetch_run_from_db(&db_path, run_id) {
//         Ok(run) => {
//             // Return the run data as a string (this can be serialized to JSON or similar)
//             format!("{:?}", run)  // For now, use debug formatting
//         }
//         Err(e) => {
//             // Handle the error and return it
//             format!("Error fetching run: {}", e)
//         }
//     }
// }

#[flutter_rust_bridge::frb(sync)]
pub fn get_run_from_db(run_id: i32, db_path: String) -> Result<Run, String> {
    // Call the top-level fetch function in queries
    match fetch_run_from_db(&db_path, run_id) {
        Ok(run) => {
            // Return the Run struct directly
            Ok(run)
        }
        Err(e) => {
            // If an error occurs, return it as a String
            Err(format!("Error fetching run: {}", e))
        }
    }
}
