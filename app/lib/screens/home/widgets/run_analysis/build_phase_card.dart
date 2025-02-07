import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_card_body.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_card_header.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/generate_phase_rows.dart';
import 'package:rust_core/rust_core.dart';

/// Builds a phase card widget, displaying phase-specific information like shields, legs, body, and pylons.
///
/// [index] The index used to determine which phase's data is displayed.
/// [context] The build context used for widget rendering and theme access.
/// [screenWidth] The width of the screen, used to adjust the card width responsively.
/// [phases] A list of [PhaseModel] objects representing different phases in the run.
/// [isBuggedRun] A boolean flag indicating whether the run was bugged, affecting the display of certain elements.
/// [flightTime] The total flight time, used for phase-specific calculations and headers.
/// [isCompact] A boolean flag that determines if the card should be displayed in a compact format.
///
/// Returns a [Widget] representing the phase card, which includes:
/// - A responsive width based on the screen size.
/// - A header section showing the phase title and total time for that phase.
/// - A body section containing the various phase data (shields, legs, body, pylons) with dynamic styling and calculated values.
/// - The height of the card adjusts based on [index] and [isCompact] setting.
Widget buildPhaseCard(
  int index,
  BuildContext context,
  double screenWidth,
  List<PhaseModel> phases,
  bool isBuggedRun,
  double flightTime,
  bool isCompact,
) {
  final PhaseModel phase = phases[index];
  final double responsiveCardWidth = screenWidth / 2;

  List<String> labels = [
    FlutterI18n.translate(context, "phase_cards.shields"),
    FlutterI18n.translate(context, "phase_cards.legs"),
    FlutterI18n.translate(context, "phase_cards.body"),
    FlutterI18n.translate(context, "phase_cards.pylons"),
  ];

  List<String> overviewList = [
    phase.totalShieldTime.toStringAsFixed(3),
    phase.totalLegTime.toStringAsFixed(3),
    phase.totalBodyKillTime.toStringAsFixed(3),
    phase.totalPylonTime.toStringAsFixed(3),
  ];

  List<Widget> rows =
      generatePhaseRows(index, labels, overviewList, isBuggedRun, context);

  return Container(
    width: screenWidth < LayoutConstants.minimumResponsiveWidth
        ? LayoutConstants.phaseCardWidth
        : responsiveCardWidth,
    height: isCompact
        ? (index == 1 && screenWidth < LayoutConstants.minimumResponsiveWidth)
            ? 110
            : (index == 3 &&
                    screenWidth < LayoutConstants.minimumResponsiveWidth)
                ? 140
                : 160
        : 160,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: <Widget>[
        buildCardHeader(phase, context, index, phases, flightTime),
        buildCardBody(rows, phase, index, context, isBuggedRun),
      ],
    ),
  );
}
