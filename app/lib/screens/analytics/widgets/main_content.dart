import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/analytics/ui/average_cards_section.dart';
import 'package:profit_taker_analyzer/screens/analytics/ui/graph_widget.dart';
import 'package:rust_core/rust_core.dart';
import 'package:screenshot/screenshot.dart';

/// A widget that represents the main content of the analytics screen.
///
/// This widget includes average time cards and a graph to display analytics data.
/// It uses a [ScreenshotController] to capture screenshots of the content and
/// passes the relevant data (average times and run times) to the child widgets.
class AnalyticsMainContent extends StatelessWidget {
  /// The width of the screen to adjust content layout.
  final double screenWidth;

  /// The controller used for capturing screenshots.
  final ScreenshotController screenshotController;

  /// The average time data for analytics.
  final TimeTypeModel? averageTimes;

  /// The list of run times to display in the graph.
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
