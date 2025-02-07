import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/analytics/ui/average_cards_section.dart';
import 'package:profit_taker_analyzer/screens/analytics/ui/graph_widget.dart';
import 'package:rust_core/rust_core.dart';
import 'package:screenshot/screenshot.dart';

class AnalyticsMainContent extends StatelessWidget {
  final double screenWidth;
  final ScreenshotController screenshotController;
  final TimeTypeModel? averageTimes;
  final List<AnalyticsRunTotalTimesModel> runTimes;

  const AnalyticsMainContent({
    super.key,
    required this.screenWidth,
    required this.screenshotController,
    required this.averageTimes,
    required this.runTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Column(
        children: [
          const SizedBox(height: 15),
          AverageCardsSection(
            screenWidth: screenWidth,
            averageTimes: averageTimes ??
                TimeTypeModel(
                  totalTime: 0,
                  flightTime: 0,
                  shieldTime: 0,
                  legTime: 0,
                  bodyTime: 0,
                  pylonTime: 0,
                ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GraphWidget(
              runInfo: runTimes,
            ),
          ),
        ],
      ),
    );
  }
}
