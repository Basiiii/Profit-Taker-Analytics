import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/utils/build_row.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:rust_core/rust_core.dart';

Widget buildPhaseCard(
  int index,
  BuildContext context,
  double screenWidth,
  List<PhaseModel> phases,
  bool isBuggedRun,
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
    height: 160,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: <Widget>[
        buildCardHeader(phase, context, index, phases),
        buildCardBody(rows, phase, index, context, isBuggedRun),
      ],
    ),
  );
}

// Helper: Generate Phase Rows
List<Widget> generatePhaseRows(
  int index,
  List<String> labels,
  List<String> overviewList,
  bool isBuggedRun,
  BuildContext context,
) {
  List<Widget> rows;

  if (index == 1) {
    rows = labels.sublist(1, 3).asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key], false);
    }).toList();
  } else if (index == 2) {
    rows = labels.asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key],
          entry.key == 3 && isBuggedRun);
    }).toList();
  } else if (index == 3) {
    rows = labels.sublist(0, 3).asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key],
          entry.key == 0 && isBuggedRun);
    }).toList();
  } else {
    rows = labels.asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key], false);
    }).toList();
  }
  return rows;
}

// Helper: Build Card Header
Widget buildCardHeader(PhaseModel phase, BuildContext context, int index,
    List<PhaseModel> phases) {
  // Calculate total time up until this phase
  double totalTimeUpUntilNow = 0;

  // Loop through all previous phases and add their times
  for (int i = 0; i <= index; i++) {
    totalTimeUpUntilNow += phases[i].totalTime;
  }

  return Padding(
    padding: const EdgeInsets.only(top: 10, left: 20, right: 10),
    child: Row(
      children: <Widget>[
        // Left side: Time for this phase
        Expanded(
          child: Text(
            FlutterI18n.translate(
                context, "phase_cards.phase_${phase.phaseNumber}"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              children: <Widget>[
                generateRichText(
                  context,
                  [
                    // "TIME FOR PHASE"
                    if (index != 0) // only for phase 2, 3 and 4
                      generateTextSpan(
                        phase.totalTime.toStringAsFixed(3),
                        16,
                        FontWeight.w400,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    if (index != 0) // only for phase 2, 3 and 4
                      generateTextSpan(
                        's / ',
                        16,
                        FontWeight.w400,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    // "TOTAL TIME"
                    generateTextSpan(totalTimeUpUntilNow.toStringAsFixed(3), 20,
                        FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface),
                    generateTextSpan('s ', 20, FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper: Build Card Body
Widget buildCardBody(List<Widget> rows, PhaseModel phase, int index,
    BuildContext context, bool isBuggedRun) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, left: 20),
    child: IntrinsicHeight(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          const SizedBox(
            width: 30,
            child: VerticalDivider(
              thickness: 2,
              width: 100,
              color: Color(0xFFAFAFAF),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildShieldsInfo(index, phase, context, isBuggedRun),
                  index != 1
                      ? const SizedBox(height: 6)
                      : const SizedBox.shrink(),
                  buildLegsInfo(phase, context),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper: Build Shields Info
Widget buildShieldsInfo(
    int index, PhaseModel phase, BuildContext context, bool isBuggedRun) {
  if (index == 1) return const SizedBox.shrink();

  return Wrap(
    spacing: 20.0,
    runSpacing: 8.0,
    direction: Axis.horizontal,
    children: phase.shieldChanges.map((pair) {
      bool isFirstPairAndIndexThreeAndBuggedRun =
          index == 3 && pair == phase.shieldChanges.first && isBuggedRun;
      return SizedBox(
        width: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(getStatusEffectIcon(pair.statusEffect), size: 13),
            Text(
              pair.shieldTime.toStringAsFixed(3),
              style: TextStyle(
                fontFamily: 'DMMono',
                fontSize: 12,
                color: isFirstPairAndIndexThreeAndBuggedRun
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

// Helper: Build Legs Info
Widget buildLegsInfo(PhaseModel phase, BuildContext context) {
  return Wrap(
    spacing: 20.0,
    runSpacing: 8.0,
    direction: Axis.horizontal,
    children: phase.legBreaks.map((pair) {
      return SizedBox(
        width: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(getLegPositionIcon(pair.legPosition), size: 8),
            Text(
              pair.legBreakTime.toStringAsFixed(3),
              style: TextStyle(
                fontFamily: 'DMMono',
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
