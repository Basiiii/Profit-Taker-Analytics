import 'package:flutter/material.dart';

class AverageCards {
  final Color color;
  final IconData icon;
  final String title;
  String time;

  AverageCards({
    required this.color,
    required this.icon,
    required this.title,
    required this.time,
  });
}

List<AverageCards> averageCards = [
  AverageCards(
    color: const Color(0xFF68ADFF),
    icon: Icons.access_time,
    title: "total_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFFFFB054),
    icon: Icons.flight,
    title: "flight_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFF7C8AE7),
    icon: Icons.shield,
    title: "shield_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFF59D5D9),
    icon: Icons.airline_seat_legroom_extra,
    title: "leg_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFFDB5858),
    icon: Icons.my_location,
    title: "body_avg",
    time: "0.000",
  ),
  AverageCards(
    color: const Color(0xFFE888DE),
    icon: Icons.workspaces_outline,
    title: "pylon_avg",
    time: "0.000",
  ),
];
