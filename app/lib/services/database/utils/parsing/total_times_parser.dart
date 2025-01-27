import 'package:profit_taker_analyzer/models/total_times.dart';

class TotalTimesParser {
  static TotalTimes parse(Map<String, dynamic> row) {
    return TotalTimes(
      totalTime: row['total_time']?.toDouble() ?? 0.0,
      totalFlight: row['total_flight']?.toDouble() ?? 0.0,
      totalShield: row['total_shield']?.toDouble() ?? 0.0,
      totalLeg: row['total_leg']?.toDouble() ?? 0.0,
      totalBody: row['total_body']?.toDouble() ?? 0.0,
      totalPylon: row['total_pylon']?.toDouble() ?? 0.0,
    );
  }
}
