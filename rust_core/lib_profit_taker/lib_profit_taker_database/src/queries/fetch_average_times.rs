use rusqlite::{Connection, Result as RusqliteResult};
use crate::connection::get_db_path;

// Struct representing the different time types
pub struct TimeType {
    pub total_time: f64,
    pub flight_time: f64,
    pub shield_time: f64,
    pub leg_time: f64,
    pub body_time: f64,
    pub pylon_time: f64,
}

// Fetches the average times for valid solo, non-bugged, and non-aborted runs
// Returns a tuple with average times for each relevant time type
pub fn fetch_average_times_query() -> RusqliteResult<(f64, f64, f64, f64, f64, f64)> {
    // Open the connection to the database
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path)?;

    // SQL query to calculate the average times for solo, non-bugged, and non-aborted runs
    let query = "
        SELECT 
            AVG(total_time),
            AVG(total_flight_time),
            AVG(total_shield_time),
            AVG(total_leg_time),
            AVG(total_body_time),
            AVG(total_pylon_time)
        FROM runs
        WHERE solo_run = 1
            AND bugged_run = 0
            AND aborted_run = 0
    ";

    // Execute the query and get the averages
    let mut stmt = conn.prepare(query)?;
    let averages = stmt.query_row([], |row| {
        Ok((
            row.get(0)?, // Average total_time
            row.get(1)?, // Average total_flight_time
            row.get(2)?, // Average total_shield_time
            row.get(3)?, // Average total_leg_time
            row.get(4)?, // Average total_body_time
            row.get(5)?, // Average total_pylon_time
        ))
    })?;

    // Return the calculated averages
    Ok(averages)
}
