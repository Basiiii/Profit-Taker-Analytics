use lib_profit_taker_core::{Run, TotalTimes};
use rusqlite::{Connection, Result as RusqliteResult};
use crate::connection::get_db_path;

pub fn fetch_paginated_runs_query(
  page: i32,
  page_size: i32,
  sort_column: &str,
  sort_ascending: bool,
) -> RusqliteResult<(Vec<Run>, i32)> {
  // Calculate the offset based on the page and page size
  let offset = (page - 1) * page_size;
  let sort_order = if sort_ascending { "ASC" } else { "DESC" };

  // Build the SQL query with pagination and sorting
  let query = format!(
      "SELECT id, run_name, time_stamp, total_time, bugged_run, aborted_run, player_name
       FROM runs
       ORDER BY {} {} LIMIT {} OFFSET {}",
      sort_column, sort_order, page_size, offset
  );

  // Open the connection to the database
  let db_path = get_db_path()?;
  let conn = Connection::open(&db_path)?;

  // Execute the query to fetch the runs
  let mut stmt = conn.prepare(&query)?;
  let run_rows = stmt.query_map([], |row| {
      Ok(Run {
          run_id: row.get(0)?,
          time_stamp: row.get(2)?,
          run_name: row.get(1)?,
          player_name: row.get(6)?,
          is_bugged_run: row.get(4)?,
          is_aborted_run: row.get(5)?,
          is_solo_run: false,
          total_times: TotalTimes::default(),
          phases: Vec::new(),
          squad_members: Vec::new(),
      })
  })?;

  // Collect the results into a Vec<Run>
  let mut runs = Vec::new();
  for run in run_rows {
      runs.push(run?);
  }

  // Query for the total count of runs (for pagination)
  let total_count_query = "SELECT COUNT(*) FROM runs";
  let mut stmt_total = conn.prepare(total_count_query)?;
  let total_count: i32 = stmt_total.query_row([], |row| row.get(0))?;

  // Return the results and total count
  Ok((runs, total_count))
}
