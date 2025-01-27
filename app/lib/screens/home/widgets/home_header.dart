import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:profit_taker_analyzer/widgets/theme_switcher.dart';

class HomeHeader extends StatelessWidget {
  final String appName;
  final String username;
  final bool compactModeEnabled;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onForwardButtonPressed;
  final VoidCallback onToggleCompactMode;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeHeader({
    super.key,
    required this.appName,
    required this.username,
    required this.compactModeEnabled,
    required this.onBackButtonPressed,
    required this.onForwardButtonPressed,
    required this.onToggleCompactMode,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            titleText(appName, 32, FontWeight.bold),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: onBackButtonPressed,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: onForwardButtonPressed,
                  ),
                  IconButton(
                    icon: Icon(compactModeEnabled
                        ? Icons.table_rows_rounded
                        : Icons.view_agenda),
                    onPressed: onToggleCompactMode,
                  ),
                  const ThemeSwitcher(),
                ],
              ),
            ),
          ],
        ),
        titleText(
          username.isEmpty
              ? FlutterI18n.translate(context, "home.hello")
              : FlutterI18n.translate(context, "home.hello_name",
                  translationParams: {"name": username}),
          24,
          FontWeight.normal,
        ),
      ],
    );
  }
}
