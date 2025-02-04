//! This module defines the `LegBreak` struct, which represents a leg break event during a phase.
//! A `LegBreak` includes the position of the leg that was broken and the order in which it was broken.

use crate::models::LegPosition;

/// Represents a leg break event during a phase.
///
/// A `LegBreak` contains information about the position of the leg that was broken and the order
/// in which it was broken relative to other leg breaks in the same phase.
/// 
/// # Fields
/// 
/// * `leg_break_time` - The time it took to break the leg.
/// * `leg_position` - The position of the leg that was broken.
/// * `leg_order` - The order in which the leg was broken (e.g., 1 for the first leg, 2 for the second, etc.).
#[derive(Debug, Clone)]
pub struct LegBreak {
    /// The time it took to break the leg
    pub leg_break_time: f64,
    
    /// The position of the leg that was broken.
    pub leg_position: LegPosition,

    /// The order in which the leg was broken (e.g., 1 for the first leg, 2 for the second, etc.).
    pub leg_order: i32,
}

impl LegBreak {
    /// Creates a new `LegBreak` instance with the specified `leg_position` and `leg_order`.
    ///
    /// # Arguments
    ///
    /// * `leg_position` - The position of the leg that was broken.
    /// * `leg_order` - The order in which the leg was broken.
    ///
    /// # Returns
    ///
    /// A new `LegBreak` instance with the provided `leg_position` and `leg_order`.
    #[must_use] pub const fn new(leg_break_time : f64, leg_position: LegPosition, leg_order: i32) -> Self {
        Self {
            leg_break_time,
            leg_position,
            leg_order,
        }
    }
}
