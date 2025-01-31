use lib_profit_taker_core::{Run, TotalTimes};
use crate::error::{Result, DataError};
use rusqlite::Connection;
use super::{SquadMemberRepository, PhaseRepository};

pub struct RunRepository<'a> {
    conn: &'a Connection,
}

impl<'a> RunRepository<'a> {
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    pub fn get_run(&self, run_id: i32) -> Result<Run> {
        // Get all data directly using the connection
        let run = self.get_run_data(self.conn, run_id)?;
        
        // Get squad members
        let squad_repo = SquadMemberRepository::new(self.conn);
        let squad_members = squad_repo.get_for_run(run_id)?;
        
        // Get phases with their details
        let phase_repo = PhaseRepository::new(self.conn);
        let phases = phase_repo.get_for_run(run_id)?;

        Ok(Run {
            run_id,
            time_stamp: run.time_stamp,
            run_name: run.run_name,
            player_name: run.player_name,
            is_bugged_run: run.is_bugged_run,
            is_aborted_run: run.is_aborted_run,
            is_solo_run: run.is_solo_run,
            total_times: run.total_times,
            phases,
            squad_members,
        })
    }

    fn get_run_data(&self, conn: &Connection, run_id: i32) -> Result<Run> {
        let mut stmt = conn.prepare(
            r#"SELECT 
                id,
                time_stamp,
                run_name,
                player_name,
                bugged_run,
                aborted_run,
                solo_run,
                total_time,
                total_flight_time,
                total_shield_time,
                total_leg_time,
                total_body_time,
                total_pylon_time
            FROM runs 
            WHERE id = ?"#,
        )?;

        let mut rows = stmt.query([run_id])?;
        let row = rows.next()?.ok_or(DataError::NotFound)?;

        Ok(Run {
            run_id: row.get(0)?,
            time_stamp: row.get(1)?,
            run_name: row.get(2)?,
            player_name: row.get(3)?,
            is_bugged_run: row.get::<_, i64>(4)? != 0,
            is_aborted_run: row.get::<_, i64>(5)? != 0,
            is_solo_run: row.get::<_, i64>(6)? != 0,
            total_times: TotalTimes {
                total_time: row.get(7)?,
                total_flight_time: row.get(8)?,
                total_shield_time: row.get(9)?,
                total_leg_time: row.get(10)?,
                total_body_time: row.get(11)?,
                total_pylon_time: row.get(12)?,
            },
            phases: Vec::new(),
            squad_members: Vec::new(),
        })
    }
}
