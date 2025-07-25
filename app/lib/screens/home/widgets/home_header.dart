import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/record_runs_dialog.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_actions.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_subtitle.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_title.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/submit_run_dialog.dart';
import 'package:profit_taker_analyzer/screens/storage/utils/delete_run.dart';

/// A widget that represents the header section of the home screen.
///
/// The header consists of the app name, navigation actions for the current run,
/// and a subtitle showing the username of the current player or a greeting message.
///
/// [scaffoldKey] The key for the [Scaffold] widget, used for managing navigation and drawer interactions.
///
/// This widget is typically used in the home screen of the app to provide navigation and layout controls
/// along with a personalized greeting.
class HomeHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeHeader({
    super.key,
    required this.scaffoldKey,
  });

  void _showSubmitRunDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SubmitRunDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final runService = context.watch<RunNavigationService>();
    final layoutPrefs = context.watch<LayoutPreferences>();
    final user = Supabase.instance.client.auth.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const HeaderTitle(title: AppConstants.appName),
            HeaderActions(
              actions: [
                if (user != null)
                  IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: () => _showSubmitRunDialog(context),
                    tooltip: FlutterI18n.translate(context, "home.submit_run"),
                  ),
                // Delete run button
                if (runService.currentRun != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final runId = runService.currentRun!.runId;
                      final deleted = await deleteRun(context, runId);
                      if (deleted) {
                        // Try to navigate to the next run, or previous if at end
                        await runService.navigateToNextRun();
                        // If still on the same run (no next), try previous
                        if (runService.currentRun?.runId == runId) {
                          await runService.navigateToPreviousRun();
                        }
                      }
                    },
                    tooltip:
                        FlutterI18n.translate(context, "tooltips.delete_run"),
                  ),
                // Icon button for navigating to the next run
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: runService.navigateToNextRun,
                  tooltip: FlutterI18n.translate(context, "tooltips.next_run"),
                ),
                // Icon button for navigating to the previous run
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: runService.navigateToPreviousRun,
                  tooltip:
                      FlutterI18n.translate(context, "tooltips.previous_run"),
                ),
                IconButton(
                  icon: Icon(MdiIcons.medal),
                  onPressed: () => showRecordRunsDialog(context),
                  tooltip: FlutterI18n.translate(context, "tooltips.view_pb"),
                ),
                // Icon button for toggling the compact mode layout
                IconButton(
                  icon: Icon(layoutPrefs.compactMode
                      ? Icons.table_rows_rounded
                      : Icons.view_agenda),
                  onPressed: layoutPrefs.toggleCompactMode,
                  tooltip:
                      FlutterI18n.translate(context, "tooltips.toggle_layout"),
                ),
              ],
            ),
          ],
        ),
        // Display the subtitle with a personalized greeting and/or username
        HeaderSubtitle(
          text: _buildUsernameText(context, runService),
        ),
      ],
    );
  }

  /// Builds a greeting message with the current username or a default greeting.
  ///
  /// This function generates a personalized greeting if a username is available,
  /// otherwise, it returns a default greeting message.
  ///
  /// [context] The build context used for localization.
  /// [service] The instance of [RunNavigationService] used to retrieve the current player's username.
  ///
  /// Returns a greeting string which is either a personalized greeting or a default one.
  String _buildUsernameText(
      BuildContext context, RunNavigationService service) {
    final username = service.currentRun?.playerName ?? '';
    return username.isEmpty
        ? FlutterI18n.translate(context, "home.hello")
        : FlutterI18n.translate(context, "home.hello_name",
            translationParams: {"name": username});
  }
}
