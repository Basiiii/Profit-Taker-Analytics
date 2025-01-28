import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/models/run_data.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/compact_run_analysis.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/home_header.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_title.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/standard_run_analysis.dart';
import 'package:profit_taker_analyzer/services/screenshot_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class HomeContent extends StatelessWidget {
  final Run runData;

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
              runName: runData.runName,
              mostRecentRun: true, // Update this logic if needed
              soloRun: runData.issoloRun,
              players: runData.squadMembers
                  .map((member) => member.playerName)
                  .toList(),
            ),
            const SizedBox(height: 15),
            _buildAnalysisSection(context),
          ],
        ),
      ),
    );
  }

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
