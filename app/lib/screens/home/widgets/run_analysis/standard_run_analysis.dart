import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/standard_view/overview_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/standard_view/phase_card.dart';
import 'package:rust_core/rust_core.dart';

class StandardRunAnalysis extends StatelessWidget {
  final RunModel runData;

  const StandardRunAnalysis({super.key, required this.runData});

  Future<Map<String, dynamic>> fetchComparisonTimes() async {
    bool isPb = isRunPb(runId: runData.runId);
    RunTimesResponse? comparisonTimes =
        isPb ? await getSecondBestTimes() : await getPbTimes();

    if (comparisonTimes == null) {
      return {
        "times": List.filled(6, 0.0), // Default values if no data is found
        "isComparingToPB": !isPb, // If not PB, we're comparing to PB
      };
    }

    return {
      "times": [
        comparisonTimes.totalTime,
        comparisonTimes.totalFlightTime,
        comparisonTimes.totalShieldTime,
        comparisonTimes.totalLegTime,
        comparisonTimes.totalBodyTime,
        comparisonTimes.totalPylonTime,
      ],
      "isComparingToPB": !isPb, // If this is a PB, we're comparing to 2nd best
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width -
        LayoutConstants.totalLeftPaddingHome -
        13;

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchComparisonTimes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text("Error loading PB data");
        }

        List<double> bestValues = snapshot.data!["times"];
        bool isComparingToPB = snapshot.data!["isComparingToPB"];

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
                      bestValues,
                      isComparingToPB,
                      runData.isBuggedRun,
                      runData.isAbortedRun
                    )),
            ...List.generate(
                4,
                (index) => buildPhaseCard(
                      index,
                      context,
                      screenWidth,
                      runData.phases,
                      runData.isBuggedRun
                    )),
          ],
        );
      },
    );
  }
}
