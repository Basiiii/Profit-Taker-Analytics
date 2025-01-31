use lib_profit_taker_core::{ShieldChange, StatusEffect};
use crate::error::{Result, DataError};
use rusqlite::Connection;

pub struct ShieldChangeRepository<'a> {
    conn: &'a Connection,
}

impl<'a> ShieldChangeRepository<'a> {
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    pub fn get_for_phase(&self, run_id: i32, phase_number: i32) -> Result<Vec<ShieldChange>> {
        let mut stmt = self.conn.prepare(
            r#"SELECT 
                shield_time,
                status_effect_id
            FROM shield_changes
            WHERE run_id = ? AND phase_number = ?
            ORDER BY shield_time"#,
        )?;

        let changes = stmt.query_map([run_id, phase_number], |row| {
            let effect_id: i32 = row.get(1)?;
            let status_effect = match effect_id {
                1 => StatusEffect::Impact,
                2 => StatusEffect::Puncture,
                3 => StatusEffect::Slash,
                4 => StatusEffect::Heat,
                5 => StatusEffect::Cold,
                6 => StatusEffect::Electric,
                7 => StatusEffect::Toxin,
                8 => StatusEffect::Blast,
                9 => StatusEffect::Radiation,
                10 => StatusEffect::Gas,
                11 => StatusEffect::Magnetic,
                12 => StatusEffect::Viral,
                13 => StatusEffect::Corrosive,
                _ => return Err(rusqlite::Error::FromSqlConversionFailure(
                    1,
                    rusqlite::types::Type::Integer,
                    Box::new(DataError::InvalidData(format!(
                        "Invalid status effect ID: {}", effect_id
                    ))),
                )),
            };

            Ok(ShieldChange {
                shield_time: row.get(0)?,
                status_effect,
            })
        })?;

        changes.collect::<std::result::Result<Vec<_>, _>>()
            .map_err(|e| DataError::InvalidData(format!(
                "Invalid shield change data: {}", e
            )))
    }
}
