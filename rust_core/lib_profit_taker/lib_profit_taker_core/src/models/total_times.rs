//! This module defines the `TotalTimes` struct, which represents the total times for various parts of a run.
//! A `TotalTimes` instance tracks the total time spent on different aspects of the run, such as the overall time, flight time, shield time, leg time, body time, and pylon time.

/// Represents the total times for various parts of a run.
///
/// The `TotalTimes` struct is used to track the total time spent on different aspects of a run,
/// such as the overall time, flight time, shield time, leg time, body time, and pylon time.
/// This is useful for analyzing and summarizing the performance of a run.
#[derive(Debug, Default)]
pub struct TotalTimes {
    /// The total time spent on the run.
    pub total_time: f64,

    /// The total time spent in flight during the run.
    pub total_flight_time: f64,

    /// The total time spent on shield-related activities during the run.
    pub total_shield_time: f64,

    /// The total time spent on leg-related activities during the run.
    pub total_leg_time: f64,

    /// The total time spent on body-related activities during the run.
    pub total_body_time: f64,

    /// The total time spent on pylon-related activities during the run.
    pub total_pylon_time: f64,
}

impl TotalTimes {
    /// Creates a new `TotalTimes` instance with the specified times.
    ///
    /// # Arguments
    ///
    /// * `total_time` - The total time spent on the run.
    /// * `total_flight_time` - The total time spent in flight during the run.
    /// * `total_shield_time` - The total time spent on shield-related activities during the run.
    /// * `total_leg_time` - The total time spent on leg-related activities during the run.
    /// * `total_body_time` - The total time spent on body-related activities during the run.
    /// * `total_pylon_time` - The total time spent on pylon-related activities during the run.
    ///
    /// # Returns
    ///
    /// A new `TotalTimes` instance with the provided times.
    ///
    /// # Examples
    ///
    /// ```
    /// use models::total_times::TotalTimes;
    ///
    /// let times = TotalTimes::new(120.5, 30.0, 20.0, 15.0, 10.0, 5.0);
    /// assert_eq!(times.total_time, 120.5);
    /// assert_eq!(times.total_flight_time, 30.0);
    /// ```
    #[must_use] pub const fn new(
        total_time: f64,
        total_flight_time: f64,
        total_shield_time: f64,
        total_leg_time: f64,
        total_body_time: f64,
        total_pylon_time: f64,
    ) -> Self {
        Self {
            total_time,
            total_flight_time,
            total_shield_time,
            total_leg_time,
            total_body_time,
            total_pylon_time,
        }
    }
}
