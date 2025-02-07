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
