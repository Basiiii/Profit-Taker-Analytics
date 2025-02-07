import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_card_body.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_card_header.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/generate_phase_rows.dart';
import 'package:rust_core/rust_core.dart';

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
