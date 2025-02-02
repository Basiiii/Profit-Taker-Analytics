import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/standard_view/overview_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/standard_view/phase_card.dart';
import 'package:rust_core/rust_core.dart';

class StandardRunAnalysis extends StatelessWidget {
  final RunModel runData;

  const StandardRunAnalysis({super.key, required this.runData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width -
        LayoutConstants.totalLeftPaddingHome -
        13;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        ...List.generate(
            6,
            (index) => buildOverviewCard(
                  index,
                  context,
                  screenWidth,
                  runData.totalTimes,
                  List.filled(6, 0.0),
                )),
        ...List.generate(
            4,
            (index) => buildPhaseCard(
                  index,
                  context,
                  screenWidth,
                  runData.phases,
                  runData.isBuggedRun,
                )),
      ],
    );
  }
}
