import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/utils/formatting/replace_new_lines.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:profit_taker_analyzer/app_layout.dart';
import 'package:rust_core/rust_core.dart';

/// Displays a dialog showing the record run times (Personal Best and Second Best).
///
/// This function retrieves run times asynchronously and displays them in an alert dialog.
///
/// - [context]: The BuildContext used to show the dialog.
void showRecordRunsDialog(BuildContext context) {
  Future.wait([getPbTimes(), getSecondBestTimes()]).then((results) {
    final pbRun = results[0];
    final sbRun = results[1];

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(FlutterI18n.translate(context, "record_runs.title")),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                    child: _buildRunSection(
                        context,
                        FlutterI18n.translate(context, "record_runs.pb"),
                        pbRun)),
                SizedBox(width: 50),
                Flexible(
                    child: _buildRunSection(
                        context,
                        FlutterI18n.translate(context, "record_runs.sb"),
                        sbRun)),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(FlutterI18n.translate(context, "common.ok")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  });
}

/// Builds a section displaying run details.
///
/// - [context]: The BuildContext used for translations.
/// - [title]: The title of the section.
/// - [run]: The run data to be displayed.
Widget _buildRunSection(
    BuildContext context, String title, RunTimesResponse? run) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      if (run != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.total_duration"))}: ${run.totalTime.toStringAsFixed(3)}s\n'
              '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.flight_time"))}: ${run.totalFlightTime.toStringAsFixed(3)}s\n'
              '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.shield_break"))}: ${run.totalShieldTime.toStringAsFixed(3)}s\n'
              '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.leg_break"))}: ${run.totalLegTime.toStringAsFixed(3)}s\n'
              '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.body_kill"))}: ${run.totalBodyTime.toStringAsFixed(3)}s\n'
              '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.pylon_destruction"))}: ${run.totalPylonTime.toStringAsFixed(3)}s',
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Close the dialog first
                  Navigator.of(context).pop();
                  
                  // Get the RunNavigationService
                  final runNavigationService = Provider.of<RunNavigationService>(
                    context, 
                    listen: false
                  );
                  
                  // Navigate to the specific run
                  await runNavigationService.maybeNavigateToRun(run.runId);
                  
                  // Switch to the home tab
                  AppLayout.globalKey.currentState?.selectTab(0);
                },
                child: Text(FlutterI18n.translate(context, "common.view")),
              ),
            ),
          ],
        )
      else
        Text("No data available"),
    ],
  );
}
