//! This module defines the `ShieldChange` struct, which represents a change in shield status during a phase.
//! A `ShieldChange` includes the time at which the shield change occurred and the associated status effect.

use crate::models::StatusEffect;

/// Represents a change in shield status during a phase.
///
/// A `ShieldChange` contains information about the time at which the shield change occurred and the
/// associated status effect that caused or resulted from the change.
#[derive(Debug)]
pub struct ShieldChange {
    /// The time at which the shield change occurred.
    pub shield_time: f64,

    /// The status effect associated with the shield change.
    pub status_effect: StatusEffect,
}

impl ShieldChange {
    /// Creates a new `ShieldChange` instance with the specified `shield_time` and `status_effect`.
    ///
    /// # Arguments
    ///
    /// * `shield_time` - The time at which the shield change occurred.
    /// * `status_effect` - The status effect associated with the shield change.
    ///
    /// # Returns
    ///
    /// A new `ShieldChange` instance with the provided `shield_time` and `status_effect`.
    #[must_use] pub const fn new(shield_time: f64, status_effect: StatusEffect) -> Self {
        Self {
            shield_time,
            status_effect,
        }
    }
}
