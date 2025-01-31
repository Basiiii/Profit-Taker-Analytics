// queries/fetch_run.rs

use rusqlite::Connection;
use lib_profit_taker_core::Run;
use crate::{error::Result, repositories::RunRepository};

/// Function to fetch the `Run` data from the database
/// This is a top-level function to easily call from the Flutter side.
pub fn fetch_run_from_db(db_path: &str, run_id: i32) -> Result<Run> {
    // Try to open the connection to the database
    let conn = Connection::open(db_path)?;

    // Create the RunRepository and use it to fetch the `Run`
    let run_repo = RunRepository::new(&conn);
    run_repo.get_run(run_id)
}
