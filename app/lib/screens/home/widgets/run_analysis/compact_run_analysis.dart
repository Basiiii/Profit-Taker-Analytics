import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/compact_view/compact_overview_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/compact_view/compact_phase_card.dart';
import 'package:rust_core/rust_core.dart';

class CompactRunAnalysis extends StatelessWidget {
  final RunModel runData;

  const CompactRunAnalysis({super.key, required this.runData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width -
        LayoutConstants.totalLeftPaddingHome -
        13;

    return Wrap(spacing: 12.0, runSpacing: 12.0, children: [
      ...List.generate(
          6,
          (index) => buildCompactOverviewCard(index, context, screenWidth,
              runData.totalTimes, runData.isBuggedRun, runData.isAbortedRun)),
      ...List.generate(
          4,
          (index) => buildCompactPhaseCard(
              index,
              context,
              screenWidth,
              runData.phases,
              runData.isBuggedRun,
              runData.totalTimes.totalFlightTime)),
    ]);
  }
}
