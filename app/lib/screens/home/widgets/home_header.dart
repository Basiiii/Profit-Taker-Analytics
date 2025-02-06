import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/app_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_actions.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_subtitle.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_title.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';

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
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: runService.navigateToNextRun,
                  tooltip: FlutterI18n.translate(context, "tooltips.next_run"),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: runService.navigateToPreviousRun,
                  tooltip:
                      FlutterI18n.translate(context, "tooltips.previous_run"),
                ),
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
        HeaderSubtitle(
          text: _buildUsernameText(context, runService),
        ),
      ],
    );
  }

  String _buildUsernameText(
      BuildContext context, RunNavigationService service) {
    final username = service.currentRun?.playerName ?? '';
    return username.isEmpty
        ? FlutterI18n.translate(context, "home.hello")
        : FlutterI18n.translate(context, "home.hello_name",
            translationParams: {"name": username});
  }
}
