//! This module defines the `Run` struct, which represents a single run in the application.
//! A run includes details such as the run ID, timestamp, run name, player name, and various flags
//! indicating the run's status. It also contains data about the total times, phases, and squad members
//! associated with the run.

use crate::models::{SquadMember, Phase, TotalTimes};
use std::vec::Vec;

/// Represents a single run in the application.
///
/// A `Run` contains information about the run's ID, timestamp, name, player name, and various flags
/// that indicate whether the run is bugged, aborted, or a solo run. It also includes data about the
/// total times, phases, and squad members associated with the run.
#[derive(Debug)]
pub struct Run {
    /// The unique identifier for the run. This is typically the primary key in a database.
    pub run_id: i32,

    /// The Unix timestamp indicating when the run was created or started.
    pub time_stamp: i64,

    /// The name of the run.
    pub run_name: String,

    /// The name of the player who initiated the run.
    pub player_name: String,

    /// A flag indicating whether the run is bugged.
    pub is_bugged_run: bool,

    /// A flag indicating whether the run was aborted.
    pub is_aborted_run: bool,

    /// A flag indicating whether the run is a solo run (i.e., no squad members).
    pub is_solo_run: bool,

    /// The total times associated with the run, such as total duration, split times, etc.
    pub total_times: TotalTimes,

    /// A vector of phases that make up the run.
    pub phases: Vec<Phase>,

    /// A vector of squad members participating in the run.
    pub squad_members: Vec<SquadMember>,
}

impl Run {
    /// Creates a new `Run` instance with the specified `run_id`, `time_stamp`, `run_name`, and `player_name`.
    ///
    /// # Arguments
    ///
    /// * `run_id` - The unique identifier for the run.
    /// * `time_stamp` - The Unix timestamp indicating when the run was created or started.
    /// * `run_name` - The name of the run.
    /// * `player_name` - The name of the player who initiated the run.
    ///
    /// # Returns
    ///
    /// A new `Run` instance with default values for `is_bugged_run`, `is_aborted_run`, `is_solo_run`,
    /// `total_times`, `phases`, and `squad_members`.
    #[must_use] pub fn new(run_id: i32, time_stamp: i64, run_name: &str, player_name: &str) -> Self {
        Self {
            run_id,
            time_stamp,
            run_name: run_name.to_string(),
            player_name: player_name.to_string(),
            is_bugged_run: false,
            is_aborted_run: false,
            is_solo_run: false,
            total_times: TotalTimes::default(),
            phases: Vec::new(),
            squad_members: Vec::new(),
        }
    }
}
