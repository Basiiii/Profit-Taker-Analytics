import 'package:flutter/material.dart';

import 'package:profit_taker_analyzer/theme/custom_icons.dart';

/// Custom and file name of current run
String runFileName = '';
String customRunName = '';

/// Display name(s)
String username = '';
String playersListStart = '';
String playersListEnd = '';

/// Defines if the run is solo and if it's most recent
bool soloRun = true;
bool mostRecentRun = true;

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
List<String> overviewPhase1 = ['0.000', '0.000', '0.000', '0.000'];

/// List of strings representing the overview for the second phase.
///
/// Each string in the list corresponds to a different aspect of the game:
/// - Index 0: Legs
/// - Index 1: Body
///
/// The strings represent time durations for each aspect.
List<String> overviewPhase2 = ['0.000', '0.000'];

/// List of strings representing the overview for the third phase.
///
/// Each string in the list corresponds to a different aspect of the game:
/// - Index 0: Shields
/// - Index 1: Legs
/// - Index 2: Body
/// - Index 3: Pylons
///
/// The strings represent time durations for each aspect.
List<String> overviewPhase3 = ['0.000', '0.000', '0.000', '0.000'];

/// List of strings representing the overview for the fourth phase.
///
/// Each string in the list corresponds to a different aspect of the game:
/// - Index 0: Shields
/// - Index 1: Legs
/// - Index 2: Body
///
/// The strings represent time durations for each aspect.
List<String> overviewPhase4 = ['0.000', '0.000', '0.000'];

/// List of maps representing the shields for the first phase.
///
/// Each map in the list corresponds to a shield, with the key being the icon and the value being the text.
/// Initially, this list is empty but will be populated with data fetched from an API. Max of 15 elements.
List<Map<String, dynamic>> shieldsPhase1 = [];

/// List of maps representing the shields for the third phase.
///
/// Each map in the list corresponds to a shield, with the key being the icon and the value being the text.
/// Initially, this list is empty but will be populated with data fetched from an API. Max of 15 elements.
List<Map<String, dynamic>> shieldsPhase3 = [];

/// List of maps representing the shields for the fourth phase.
///
/// Each map in the list corresponds to a shield, with the key being the icon and the value being the text.
/// Initially, this list is empty but will be populated with data fetched from an API. Max of 15 elements.
List<Map<String, dynamic>> shieldsPhase4 = [];

/// List of maps representing the legs for the first phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase1 = [
  {'icon': CustomIcons.fl, 'text': '0.000'},
  {'icon': CustomIcons.fr, 'text': '0.000'},
  {'icon': CustomIcons.bl, 'text': '0.000'},
  {'icon': CustomIcons.br, 'text': '0.000'},
];

/// List of maps representing the legs for the second phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase2 = [
  {'icon': CustomIcons.fl, 'text': '0.000'},
  {'icon': CustomIcons.fr, 'text': '0.000'},
  {'icon': CustomIcons.bl, 'text': '0.000'},
  {'icon': CustomIcons.br, 'text': '0.000'},
];

/// List of maps representing the legs for the third phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase3 = [
  {'icon': CustomIcons.fl, 'text': '0.000'},
  {'icon': CustomIcons.fr, 'text': '0.000'},
  {'icon': CustomIcons.bl, 'text': '0.000'},
  {'icon': CustomIcons.br, 'text': '0.000'},
];

/// List of maps representing the legs for the fourth phase.
///
/// Each map in the list corresponds to a leg, with the key being the icon and the value being the text.
/// The order of the legs is: Front Left, Front Right, Back Left, Back Right.
List<Map<String, dynamic>> legsPhase4 = [
  {'icon': CustomIcons.fl, 'text': '0.000'},
  {'icon': CustomIcons.fr, 'text': '0.000'},
  {'icon': CustomIcons.bl, 'text': '0.000'},
  {'icon': CustomIcons.br, 'text': '0.000'},
];

/// List of PhaseCards objects representing the phases of the game.
///
/// Each PhaseCards object represents a different phase of the game, including its title,
/// time, overview list, shields list, and legs list.
List<PhaseCards> phaseCards = [
  PhaseCards(
      title: "phase_1",
      time: "0.000",
      overviewList: overviewPhase1,
      shieldsList: shieldsPhase1,
      legsList: legsPhase1),
  PhaseCards(
      title: "phase_2",
      time: "0.000",
      overviewList: overviewPhase2,
      shieldsList: [],
      legsList: legsPhase2),
  PhaseCards(
      title: "phase_3",
      time: "0.000",
      overviewList: overviewPhase3,
      shieldsList: shieldsPhase3,
      legsList: legsPhase3),
  PhaseCards(
      title: "phase_4",
      time: "0.000",
      overviewList: overviewPhase4,
      shieldsList: shieldsPhase4,
      legsList: legsPhase4),
];

/// List of OverviewCards objects representing the overview cards.
///
/// Each OverviewCards object represents a different aspect of the game,
/// including its color, icon, title, and time.
List<OverviewCards> overviewCards = [
  OverviewCards(
    color: const Color(0xFF68ADFF),
    icon: Icons.access_time,
    title: "total_duration",
    time: "0.000",
  ),
  OverviewCards(
    color: const Color(0xFFFFB054),
    icon: Icons.flight,
    title: "flight_time",
    time: "0.000",
  ),
  OverviewCards(
    color: const Color(0xFF7C8AE7),
    icon: Icons.shield,
    title: "shield_break",
    time: "0.000",
  ),
  OverviewCards(
    color: const Color(0xFF59D5D9),
    icon: Icons.airline_seat_legroom_extra,
    title: "leg_break",
    time: "0.000",
  ),
  OverviewCards(
    color: const Color(0xFFDB5858),
    icon: Icons.my_location,
    title: "body_kill",
    time: "0.000",
  ),
  OverviewCards(
    color: const Color(0xFFE888DE),
    icon: Icons.workspaces_outline,
    title: "pylon_destruction",
    time: "0.000",
  ),
];
