//! This module defines the `Phase` struct, which represents a single phase within a run.
//! A phase includes details such as the phase number, total times for various metrics (shield, leg, body, pylon),
//! as well as a list of shield changes and leg breaks that occurred during the phase.

use crate::models::{ShieldChange, LegBreak};
use std::vec::Vec;

/// Represents a single phase within a run.
///
/// A `Phase` contains information about the phase number, total times for various metrics (shield, leg, body, pylon),
/// as well as a list of shield changes and leg breaks that occurred during the phase.
#[derive(Debug)]
pub struct Phase {
    /// The number of the phase within the run.
    pub phase_number: i32,

    /// The total time taken to complete the phase.
    pub total_time: f64,

    /// The total time spent on shield-related activities during the phase.
    pub total_shield_time: f64,

    /// The total time spent on leg-related activities during the phase.
    pub total_leg_time: f64,

    /// The total time spent on body kill-related activities during the phase.
    pub total_body_kill_time: f64,

    /// The total time spent on pylon-related activities during the phase.
    pub total_pylon_time: f64,

    /// A vector of shield changes that occurred during the phase.
    pub shield_changes: Vec<ShieldChange>,

    /// A vector of leg breaks that occurred during the phase.
    pub leg_breaks: Vec<LegBreak>,
}

impl Phase {
    /// Creates a new `Phase` instance with the specified `phase_number`.
    ///
    /// # Arguments
    ///
    /// * `phase_number` - The number of the phase within the run.
    ///
    /// # Returns
    ///
    /// A new `Phase` instance with default values for `total_time`, `total_shield_time`, `total_leg_time`,
    /// `total_body_kill_time`, `total_pylon_time`, `shield_changes`, and `leg_breaks`.
    #[must_use] pub const fn new(phase_number: i32) -> Self {
        Self {
            phase_number,
            total_time: 0.0,
            total_shield_time: 0.0,
            total_leg_time: 0.0,
            total_body_kill_time: 0.0,
            total_pylon_time: 0.0,
            shield_changes: Vec::new(),
            leg_breaks: Vec::new(),
        }
    }
}
