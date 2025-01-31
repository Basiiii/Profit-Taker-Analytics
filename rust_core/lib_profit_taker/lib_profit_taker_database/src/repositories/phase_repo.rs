use lib_profit_taker_core::{Phase, ShieldChange, LegBreak};
use crate::error::Result;
use rusqlite::{Connection, Row};
use super::{ShieldChangeRepository, LegBreakRepository};

pub struct PhaseRepository<'a> {
    conn: &'a Connection,
}

impl<'a> PhaseRepository<'a> {
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    pub fn get_for_run(&self, run_id: i32) -> Result<Vec<Phase>> {
        let mut stmt = self.conn.prepare(
            r#"SELECT 
                phase_number,
                phase_time,
                shield_time,
                leg_time,
                body_kill_time,
                pylon_time
            FROM phases 
            WHERE run_id = ? 
            ORDER BY phase_number"#,
        )?;

        let phases = stmt
            .query_map([run_id], |row| Ok(self.row_to_phase(row)))?
            .collect::<std::result::Result<Vec<_>, _>>()?;

        // Load related data for each phase
        phases
            .into_iter()
            .map(|mut phase| {
                phase.shield_changes = self.get_shield_changes(run_id, phase.phase_number)?;
                phase.leg_breaks = self.get_leg_breaks(run_id, phase.phase_number)?;
                Ok(phase)
            })
            .collect()
    }

    fn row_to_phase(&self, row: &Row) -> Phase {
        Phase {
            phase_number: row.get(0).unwrap(),
            total_time: row.get::<_, Option<f64>>(1).unwrap().unwrap_or(0.0),
            total_shield_time: row.get::<_, Option<f64>>(2).unwrap().unwrap_or(0.0),
            total_leg_time: row.get::<_, Option<f64>>(3).unwrap().unwrap_or(0.0),
            total_body_kill_time: row.get::<_, Option<f64>>(4).unwrap().unwrap_or(0.0),
            total_pylon_time: row.get::<_, Option<f64>>(5).unwrap().unwrap_or(0.0),
            shield_changes: Vec::new(),
            leg_breaks: Vec::new(),
        }
    }

    fn get_shield_changes(&self, run_id: i32, phase_number: i32) -> Result<Vec<ShieldChange>> {
        ShieldChangeRepository::new(self.conn)
            .get_for_phase(run_id, phase_number)
    }

    fn get_leg_breaks(&self, run_id: i32, phase_number: i32) -> Result<Vec<LegBreak>> {
        LegBreakRepository::new(self.conn)
            .get_for_phase(run_id, phase_number)
    }
}
