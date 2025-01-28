import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/models/run_data.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/overview/overview_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/phases/phase_card.dart';

class StandardRunAnalysis extends StatelessWidget {
  final Run runData;

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
