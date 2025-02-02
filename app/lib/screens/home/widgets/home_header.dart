import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/app_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/layout_preferences.dart';
import 'package:provider/provider.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:profit_taker_analyzer/widgets/theme_switcher.dart';

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
            titleText(AppConstants.appName, 32, FontWeight.bold),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: runService.navigateToNextRun,
                    tooltip:
                        FlutterI18n.translate(context, "tooltips.next_run"),
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
                    tooltip: FlutterI18n.translate(
                        context, "tooltips.toggle_layout"),
                  ),
                  const ThemeSwitcher(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ],
        ),
        _buildUsername(context, runService),
      ],
    );
  }

  Widget _buildUsername(BuildContext context, RunNavigationService service) {
    final username = service.currentRun?.playerName ?? '';
    return titleText(
      username.isEmpty
          ? FlutterI18n.translate(context, "home.hello")
          : FlutterI18n.translate(context, "home.hello_name",
              translationParams: {"name": username}),
      24,
      FontWeight.normal,
    );
  }
}
