import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/models/run_data.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/compact_view/compact_overview_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/compact_view/compact_phase_card.dart';

class CompactRunAnalysis extends StatelessWidget {
  final Run runData;

  const CompactRunAnalysis({super.key, required this.runData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width -
        LayoutConstants.totalLeftPaddingHome -
        13;

    return Wrap(spacing: 12.0, runSpacing: 12.0, children: [
      ...List.generate(
          6,
          (index) => buildCompactOverviewCard(
              index, context, screenWidth, runData.totalTimes)),
      ...List.generate(
          4,
          (index) => buildCompactPhaseCard(index, context, screenWidth,
              runData.phases, runData.isBuggedRun)),
    ]);
  }
}
