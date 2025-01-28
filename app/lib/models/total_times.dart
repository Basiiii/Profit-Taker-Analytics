class TotalTimes {
  double totalTime;
  double totalFlight;
  double totalShield;
  double totalLeg;
  double totalBody;
  double totalPylon;

  TotalTimes({
    required this.totalTime,
    required this.totalFlight,
    required this.totalShield,
    required this.totalLeg,
    required this.totalBody,
    required this.totalPylon,
  });

  /// Factory method to create a default instance of TotalTimes with placeholder values.
  factory TotalTimes.defaultTimes() {
    return TotalTimes(
      totalTime: 0.0,
      totalFlight: 0.0,
      totalShield: 0.0,
      totalLeg: 0.0,
      totalBody: 0.0,
      totalPylon: 0.0,
    );
  }
}
