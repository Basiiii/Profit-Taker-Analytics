//! This module defines the `LegBreak` struct, which represents a leg break event during a phase.
//! A `LegBreak` includes the position of the leg that was broken and the order in which it was broken.

use crate::models::LegPosition;

/// Represents a leg break event during a phase.
///
/// A `LegBreak` contains information about the position of the leg that was broken and the order
/// in which it was broken relative to other leg breaks in the same phase.
#[derive(Debug)]
pub struct LegBreak {
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
    pub fn new(leg_position: LegPosition, leg_order: i32) -> Self {
        LegBreak {
            leg_position,
            leg_order,
        }
    }
}
