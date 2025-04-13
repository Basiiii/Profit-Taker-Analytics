use crate::connection::get_db_path;
use rusqlite::{Connection, Result as RusqliteResult};

#[derive(Debug)]
pub struct AnalyticsRunTotalTimes {
    pub id: i32,
    pub run_name: String,
    pub total_time: f64,
    pub total_flight_time: f64,
    pub total_shield_time: f64,
    pub total_leg_time: f64,
    pub total_body_time: f64,
    pub total_pylon_time: f64,
}

pub fn fetch_analytics_runs(limit: i32) -> RusqliteResult<Vec<AnalyticsRunTotalTimes>> {
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path)?;

    let query = format!(
        "SELECT id, run_name, total_time, total_flight_time, total_shield_time, 
                total_leg_time, total_body_time, total_pylon_time 
         FROM runs 
         WHERE solo_run = 1 
         AND bugged_run = 0 
         AND aborted_run = 0
         ORDER BY time_stamp DESC 
         LIMIT {}",
        limit
    );

    let mut stmt = conn.prepare(&query)?;
    let run_rows = stmt.query_map([], |row| {
        Ok(AnalyticsRunTotalTimes {
            id: row.get(0)?,
            run_name: row.get(1)?,
            total_time: row.get(2)?,
            total_flight_time: row.get(3)?,
            total_shield_time: row.get(4)?,
            total_leg_time: row.get(5)?,
            total_body_time: row.get(6)?,
            total_pylon_time: row.get(7)?,
        })
    })?;

    let mut total_times = Vec::new();
    for run in run_rows {
        total_times.push(run?);
    }

    Ok(total_times)
}
