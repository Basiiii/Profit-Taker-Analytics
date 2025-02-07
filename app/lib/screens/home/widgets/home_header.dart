import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_actions.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_subtitle.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_title.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final runService = context.watch<RunNavigationService>();
    final layoutPrefs = context.watch<LayoutPreferences>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const HeaderTitle(title: AppConstants.appName),
            HeaderActions(
              actions: [
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
