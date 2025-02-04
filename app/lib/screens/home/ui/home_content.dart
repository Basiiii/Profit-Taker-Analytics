import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/compact_run_analysis.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/home_header.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_title.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/standard_run_analysis.dart';
import 'package:profit_taker_analyzer/services/screenshot_service.dart';
import 'package:provider/provider.dart';
import 'package:rust_core/rust_core.dart';
import 'package:screenshot/screenshot.dart';

/// A StatelessWidget that displays the main content of the home screen.
///
/// The home content includes a header, the title of the current run, and an analysis section
/// that adapts based on the layout preferences (compact or standard). The widget also supports
/// taking screenshots of the content using the [ScreenshotService].
///
/// Parameters:
/// - [runData]: The data for the current run, including run name, squad members, and solo run status.
///
/// Returns:
/// A [HomeContent] widget displaying the header, run title, and the appropriate run analysis based on layout preferences.
class HomeContent extends StatelessWidget {
  final RunModel runData;

  const HomeContent({super.key, required this.runData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 60, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(scaffoldKey: GlobalKey<ScaffoldState>()),
            const SizedBox(height: 25),
            RunTitle(
              run: runData,
              mostRecentRun: checkIfLatestRun(runId: runData.runId),
              showBestRunText: isRunPb(runId: runData.runId),
            ),
            const SizedBox(height: 15),
            _buildAnalysisSection(context),
          ],
        ),
      ),
    );
  }

  /// Builds the section of the home content that displays the run analysis.
  ///
  /// This section adapts between a compact mode and a standard mode based on the user's layout preferences.
  /// It uses the [Screenshot] widget to allow the user to capture screenshots of the analysis section.
  ///
  /// Parameters:
  /// - [context]: The build context used to access the layout preferences and screenshot service.
  ///
  /// Returns:
  /// A widget representing either a compact or standard run analysis, wrapped in a screenshot controller.
  Widget _buildAnalysisSection(BuildContext context) {
    return Consumer<LayoutPreferences>(
      builder: (context, prefs, child) {
        return Screenshot(
          controller: context.read<ScreenshotService>().controller,
          child: prefs.compactMode
              ? CompactRunAnalysis(runData: runData)
              : StandardRunAnalysis(runData: runData),
        );
      },
    );
  }
}
