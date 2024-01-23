import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/theme/custom_icons.dart';

/// Represents an overview card with a color, an icon, a title and a time.
///
/// An overview card is a simple widget that displays a color, an icon, a title and a time.
/// These properties are passed to the constructor when creating a new instance of this class.
///
/// Example usage:
/// ```dart
/// OverviewCards(color: Colors.blue,
/// icon: Icons.star,
/// title: 'Star Rating',
/// time: '12.001',
/// )
/// ```
class OverviewCards {
  final Color color;
  final IconData icon;
  final String title;
  final String time;

  /// Constructs a new instance of OverviewCards.
  ///
  /// The [color], [icon], [title] and [time] parameters must not be null.
  OverviewCards(
      {required this.color,
      required this.icon,
      required this.title,
      required this.time});
}

/// Represents a phase card with a title, time, overview list, shields list, and legs list.
///
/// A phase card is a complex widget that displays a title, time, overview list, shields list, and legs list.
/// These properties are passed to the constructor when creating a new instance of this class.
///
/// Example usage:
/// ```dart
/// PhaseCards(
///   title: 'First Phase',
///   time: '16.707',
///   overviewList: ['1.111s', '1.111s', '1.111s', '1.111s'],
///   shieldsList: [{'icon': CustomIcons.blast, 'text': '11.111s'}],
///   legsList: [{'icon': CustomIcons.fl, 'text': '21.111s'}],
/// )
/// ```
class PhaseCards {
  final String title;
  final String time;
  final List<String> overviewList;
  final List<Map<String, dynamic>> shieldsList;
  final List<Map<String, dynamic>> legsList;

  /// Constructs a new instance of PhaseCards.
  ///
  /// The [title], [time], [overviewList], [shieldsList], and [legsList] parameters must not be null.
  PhaseCards(
      {required this.title,
      required this.time,
      required this.overviewList,
      required this.shieldsList,
      required this.legsList});
}

/// List of strings representing the overview for the first phase.
///
/// Each string in the list corresponds to a different aspect of the game:
/// - Index 0: Shields
/// - Index 1: Legs
/// - Index 2: Body
/// - Index 3: Pylons
///
/// The strings represent time durations for each aspect.
List<String> overviewPhase1 = ['1.111s', '2.111s', '3.111s', '4.111s'];

/// List of strings representing the overview for the second phase.
///
/// Each string in the list corresponds to a different aspect of the game:
/// - Index 0: Legs
/// - Index 1: Body
///
/// The strings represent time durations for each aspect.
List<String> overviewPhase2 = ['1.111s', '2.111s'];

/// List of strings representing the overview for the third phase.
///
/// Each string in the list corresponds to a different aspect of the game:
/// - Index 0: Shields
/// - Index 1: Legs
/// - Index 2: Body
/// - Index 3: Pylons
///
/// The strings represent time durations for each aspect.
List<String> overviewPhase3 = ['1.111s', '2.111s', '3.111s', '4.111s'];

/// List of strings representing the overview for the fourth phase.
///
/// Each string in the list corresponds to a different aspect of the game:
/// - Index 0: Shields
/// - Index 1: Legs
/// - Index 2: Body
///
/// The strings represent time durations for each aspect.
List<String> overviewPhase4 = ['1.111s', '2.111s', '3.111s'];

/// List of maps representing the shields for the first phase.
///
/// Each map in the list corresponds to a shield, with the key being the icon and the value being the text.
/// Initially, this list is empty but will be populated with data fetched from an API.
List<Map<String, dynamic>> shieldsPhase1 = [];

/// List of maps representing the shields for the third phase.
///
/// Each map in the list corresponds to a shield, with the key being the icon and the value being the text.
/// Initially, this list is empty but will be populated with data fetched from an API.
List<Map<String, dynamic>> shieldsPhase3 = [];

/// List of maps representing the shields for the fourth phase.
///
/// Each map in the list corresponds to a shield, with the key being the icon and the value being the text.
/// Initially, this list is empty but will be populated with data fetched from an API.
List<Map<String, dynamic>> shieldsPhase4 = [];

/// List of maps representing the legs for the first phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase1 = [
  {'icon': CustomIcons.fl, 'text': '21.111s'},
  {'icon': CustomIcons.fr, 'text': '1.111s'},
  {'icon': CustomIcons.bl, 'text': '1.111s'},
  {'icon': CustomIcons.br, 'text': '1.111s'},
];

/// List of maps representing the legs for the second phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase2 = [
  {'icon': CustomIcons.fl, 'text': '1.111s'},
  {'icon': CustomIcons.fr, 'text': '1.111s'},
  {'icon': CustomIcons.bl, 'text': '1.111s'},
  {'icon': CustomIcons.br, 'text': '1.111s'},
];

/// List of maps representing the legs for the third phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase3 = [
  {'icon': CustomIcons.fl, 'text': '1.111s'},
  {'icon': CustomIcons.fr, 'text': '1.111s'},
  {'icon': CustomIcons.bl, 'text': '1.111s'},
  {'icon': CustomIcons.br, 'text': '1.111s'},
];

/// List of maps representing the legs for the fourth phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase4 = [
  {'icon': CustomIcons.fl, 'text': '1.111s'},
  {'icon': CustomIcons.fr, 'text': '1.111s'},
  {'icon': CustomIcons.bl, 'text': '1.111s'},
  {'icon': CustomIcons.br, 'text': '1.111s'},
];

/// List of PhaseCards objects representing the phases of the game.
///
/// Each PhaseCards object represents a different phase of the game, including its title,
/// time, overview list, shields list, and legs list.
List<PhaseCards> phaseCards = [
  PhaseCards(
      title: "First Phase",
      time: "16.707",
      overviewList: overviewPhase1,
      shieldsList: shieldsPhase1,
      legsList: legsPhase1),
  PhaseCards(
      title: "Second Phase",
      time: "16.707",
      overviewList: overviewPhase2,
      shieldsList: [],
      legsList: legsPhase2),
  PhaseCards(
      title: "Third Phase",
      time: "16.707",
      overviewList: overviewPhase3,
      shieldsList: shieldsPhase3,
      legsList: legsPhase3),
  PhaseCards(
      title: "Fourth Phase",
      time: "16.707",
      overviewList: overviewPhase4,
      shieldsList: shieldsPhase1,
      legsList: legsPhase4),
];

/// List of OverviewCards objects representing the overview cards.
///
/// Each OverviewCards object represents a different aspect of the game,
/// including its color, icon, title, and time.
List<OverviewCards> overviewCards = [
  OverviewCards(
    color: const Color(0xFF86BCFC),
    icon: Icons.access_time,
    title: "Total\nDuration",
    time: "57.539",
  ),
  OverviewCards(
    color: const Color(0xFFFCC686),
    icon: Icons.flight,
    title: "Flight\nTime",
    time: "3.106",
  ),
  OverviewCards(
    color: const Color(0xFFA4ADE9),
    icon: Icons.shield,
    title: "Shield\nBreak",
    time: "9.629",
  ),
  OverviewCards(
    color: const Color(0xFF84DFE2),
    icon: Icons.airline_seat_legroom_extra,
    title: "Leg\nBreak",
    time: "8.809",
  ),
  OverviewCards(
    color: const Color(0xFFE28484),
    icon: Icons.my_location,
    title: "Body\nKill",
    time: "0.029",
  ),
  OverviewCards(
    color: const Color(0xFFE9A4E2),
    icon: Icons.workspaces_outline,
    title: "Pylon\nDestruction",
    time: "16.707",
  ),
];

// TODO: Look at how we plan on storing previous run data
// NOTE: Undocumented and basic for now, was testing implementation a long time ago
List<String> previousRuns = [
  "15/11/2023 @ 15:04",
  "15/11/2023 @ 15:02",
];
