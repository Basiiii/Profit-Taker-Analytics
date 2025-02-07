import 'package:flutter/material.dart';

/// A model representing the data for each average card.
///
/// The [AverageCards] class holds information related to each average card
/// displayed in the analytics screen, including its color, icon, title, and time value.
class AverageCards {
  /// The color used for the card.
  final Color color;

  /// The icon displayed on the card.
  final IconData icon;

  /// The title or label for the card.
  final String title;

  /// The time value displayed on the card.
  String time;

  /// Creates an instance of [AverageCards].
  ///
  /// The [color], [icon], [title], and [time] parameters are required to
  /// initialize a new [AverageCards] object.
  AverageCards({
    required this.color,
    required this.icon,
    required this.title,
    required this.time,
  });
}

/// A list of predefined average cards with their respective color, icon, title, and time values.
///
/// This list is used to display different analytics metrics such as total time, flight time, shield time,
/// leg time, body time, and pylon time on the analytics screen.
List<AverageCards> averageCards = [
  AverageCards(
    color: const Color(0xFF68ADFF), // Light Blue
    icon: Icons.access_time,
    title: "total_avg", // Total Average Time
    time: "0.000", // Default value for total time
  ),
  AverageCards(
    color: const Color(0xFFFFB054), // Yellow
    icon: Icons.flight,
    title: "flight_avg", // Flight Average Time
    time: "0.000", // Default value for flight time
  ),
  AverageCards(
    color: const Color(0xFF7C8AE7), // Blue
    icon: Icons.shield,
    title: "shield_avg", // Shield Average Time
    time: "0.000", // Default value for shield time
  ),
  AverageCards(
    color: const Color(0xFF59D5D9), // Turquoise
    icon: Icons.airline_seat_legroom_extra,
    title: "leg_avg", // Leg Average Time
    time: "0.000", // Default value for leg time
  ),
  AverageCards(
    color: const Color(0xFFDB5858), // Red
    icon: Icons.my_location,
    title: "body_avg", // Body Average Time
    time: "0.000", // Default value for body time
  ),
  AverageCards(
    color: const Color(0xFFE888DE), // Light Pink
    icon: Icons.workspaces_outline,
    title: "pylon_avg", // Pylon Average Time
    time: "0.000", // Default value for pylon time
  ),
];
