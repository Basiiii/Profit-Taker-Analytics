import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/card_details.dart';
import 'package:rust_core/rust_core.dart';

CardDetails getCardDetails(
    int index, TotalTimesModel totalTimes, BuildContext context,
    {bool isCompact = false}) {
  final titles = [
    "total_duration",
    "flight_time",
    "shield_break",
    "leg_break",
    "body_kill",
    "pylon_destruction"
  ];

  final times = [
    totalTimes.totalDuration,
    totalTimes.totalFlightTime,
    totalTimes.totalShieldTime,
    totalTimes.totalLegTime,
    totalTimes.totalBodyTime,
    totalTimes.totalPylonTime
  ];

  final colors = [
    const Color(0xFF68ADFF),
    const Color(0xFFFFB054),
    const Color(0xFF7C8AE7),
    const Color(0xFF59D5D9),
    const Color(0xFFDB5858),
    const Color(0xFFE888DE)
  ];

  return CardDetails(
      colors[index],
      Icons.access_time, // Default icon
      FlutterI18n.translate(context, "overview_cards.${titles[index]}"),
      times[index]);
}
