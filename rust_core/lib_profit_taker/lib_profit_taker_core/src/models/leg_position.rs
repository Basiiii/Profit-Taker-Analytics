//! This module defines the `LegPosition` enum, which represents the position of a leg on a profit-taker.
//! The enum provides a way to categorize legs into four positions: front left, front right, back left, and back right.

/// Represents the position of a leg on a profit-taker.
///
/// The `LegPosition` enum is used to categorize legs into four distinct positions:
/// - `FrontLeft`
/// - `FrontRight`
/// - `BackLeft`
/// - `BackRight`
///
/// This is useful for tracking leg-specific events, such as leg breaks, in a structured way.
#[derive(Debug)]
pub enum LegPosition {
    /// The front left leg of the profit-taker.
    FrontLeft,

    /// The front right leg of the profit-taker.
    FrontRight,

    /// The back left leg of the profit-taker.
    BackLeft,

    /// The back right leg of the profit-taker.
    BackRight,
}

impl LegPosition {
    /// Converts a `LegPosition` variant into its string representation.
    ///
    /// # Returns
    ///
    /// A string slice (`&str`) representing the name of the `LegPosition` variant.
    ///
    /// # Examples
    ///
    /// ```
    /// use models::leg_position::LegPosition;
    ///
    /// let position = LegPosition::FrontLeft;
    /// assert_eq!(position.to_string(), "FrontLeft");
    /// ```
    #[must_use] pub const fn to_string(&self) -> &str {
        match *self {
            Self::FrontLeft => "FrontLeft",
            Self::FrontRight => "FrontRight",
            Self::BackLeft => "BackLeft",
            Self::BackRight => "BackRight",
        }
    }
}
