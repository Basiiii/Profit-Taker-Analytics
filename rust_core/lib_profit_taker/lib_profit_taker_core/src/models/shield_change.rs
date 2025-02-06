//! This module defines the `ShieldChange` struct, which represents a change in shield status during a phase.
//! A `ShieldChange` includes the time at which the shield change occurred and the associated status effect.

use crate::models::StatusEffect;

/// Represents a change in shield status during a phase.
///
/// A `ShieldChange` contains information about the time it took for the shield change to occur 
/// and the associated status effect that caused the change.
/// 
/// # Fields
/// 
/// * `shield_time` - The time at which the shield change occurred.
/// * `status_effect` - The status effect associated with the shield change.
/// * `shield_order` - The order in which the shield was changed (e.g., 1 for the first shield change, 2 for the second, etc.).
#[derive(Debug, Clone)]
pub struct ShieldChange {
    /// The time at which the shield change occurred.
    pub shield_time: f64,

    /// The status effect associated with the shield change.
    pub status_effect: StatusEffect,
    
    /// The order in which the shield was changed (e.g., 1 for the first shield change, 2 for the second, etc.).
    pub shield_order: i32,
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
    #[must_use] pub const fn new(shield_time: f64, status_effect: StatusEffect, shield_order: i32) -> Self {
        Self {
            shield_time,
            status_effect,
            shield_order,
        }
    }
}
