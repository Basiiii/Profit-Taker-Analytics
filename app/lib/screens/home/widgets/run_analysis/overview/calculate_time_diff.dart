/// Calculates the time difference between the current time and the best time,
/// and returns relevant data for display.
///
/// [currentTime] The current time being compared.
/// [bestTime] The best recorded time for comparison.
/// [isComparingToPB] A boolean flag to indicate if the comparison is to the personal best (PB).
///
/// Returns a map containing:
/// - 'difference': The absolute difference between the current and best time.
/// - 'isBetter': A boolean indicating if the current time is better than the best time.
/// - 'isComparingToPB': The flag indicating whether comparing to PB.
/// - 'differenceText': A string representing the formatted time difference with the appropriate sign.
/// - 'isNegative': A boolean indicating if the difference is negative (an improvement).
/// - 'label': A label indicating whether the comparison is to a Personal Best (PB) or Second Best (SB).
/// - 'isPB': A boolean indicating if the current time is a Personal Best (PB).
/// - 'bestTime': The best time value for display.
Map<String, dynamic> calculateTimeDifference(
    double currentTime, double bestTime, bool isComparingToPB) {
  // Calculate the difference
  double difference = currentTime - bestTime;
  bool isBetter = difference < 0;

  // Determine the text for the difference
  String differenceText = difference < 0
      ? "+${difference.abs().toStringAsFixed(3)}s"
      : "-${difference.abs().toStringAsFixed(3)}s";

  // Determine if it's a PB (Personal Best)
  bool isPB = !isComparingToPB;

  // Label for the comparison
  String label = isPB ? "SB" : "PB";

  // Return the data as a map
  return {
    'difference': difference.abs(), // Difference as absolute value
    'isBetter': isBetter, // Whether it's better than PB or not
    'isComparingToPB': isComparingToPB, // Flag to know if we're comparing to PB
    'differenceText': differenceText, // Added difference text
    'isNegative':
        difference < 0, // Whether the difference is negative (improvement)
    'label': label, // Added label for PB/2nd Best
    'isPB': isPB, // Added flag for PB
    'bestTime': bestTime // Added best time for display
  };
}
