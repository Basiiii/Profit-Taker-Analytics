use lib_profit_taker_core::{LegBreak, LegPosition};
use crate::error::{Result, DataError};
use rusqlite::Connection;

pub struct LegBreakRepository<'a> {
    conn: &'a Connection,
}

impl<'a> LegBreakRepository<'a> {
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    pub fn get_for_phase(&self, run_id: i32, phase_number: i32) -> Result<Vec<LegBreak>> {
        let mut stmt = self.conn.prepare(
            r#"SELECT 
                break_time,
                break_order,
                lp.name AS leg_position
            FROM leg_breaks lb
            JOIN leg_position lp ON lb.leg_position_id = lp.id
            WHERE run_id = ? AND phase_number = ?
            ORDER BY break_order"#,
        )?;

        let breaks = stmt.query_map([run_id, phase_number], |row| {
            let position_str: String = row.get(2)?;
            let leg_position = match position_str.as_str() {
                "FL" => LegPosition::FrontLeft,
                "FR" => LegPosition::FrontRight,
                "BL" => LegPosition::BackLeft,
                "BR" => LegPosition::BackRight,
                _ => return Err(rusqlite::Error::FromSqlConversionFailure(
                    2,
                    rusqlite::types::Type::Text,
                    Box::new(DataError::InvalidData(format!(
                        "Invalid leg position: {}", position_str
                    ))),
                )),
            };

            Ok(LegBreak {
                leg_position,
                leg_order: row.get(1)?,
            })
        })?;

        breaks.collect::<std::result::Result<Vec<_>, _>>()
            .map_err(|e| DataError::InvalidData(format!(
                "Invalid leg break data: {}", e
            )))
    }
}
