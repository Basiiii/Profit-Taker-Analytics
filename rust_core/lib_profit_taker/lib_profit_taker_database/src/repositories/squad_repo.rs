use lib_profit_taker_core::SquadMember;
use crate::error::Result;
use rusqlite::Connection;

pub struct SquadMemberRepository<'a> {
    conn: &'a Connection,
}

impl<'a> SquadMemberRepository<'a> {
    pub fn new(conn: &'a Connection) -> Self {
        Self { conn }
    }

    pub fn get_for_run(&self, run_id: i32) -> Result<Vec<SquadMember>> {
        let mut stmt = self.conn.prepare(
            "SELECT member_name FROM squad_members WHERE run_id = ? ORDER BY member_name",
        )?;

        let rows = stmt.query_map([run_id], |row| {
            Ok(SquadMember {
                member_name: row.get(0)?,
            })
        })?;

        // Collect results and convert error type
        rows.collect::<std::result::Result<Vec<_>, _>>()
            .map_err(Into::into)
    }
}
