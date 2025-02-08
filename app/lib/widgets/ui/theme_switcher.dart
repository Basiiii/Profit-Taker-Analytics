import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that allows users to toggle between light and dark themes.
///
/// The [ThemeSwitcher] uses [ThemeProvider] to determine the current theme mode
/// and updates it when the button is pressed. The selected theme preference is
/// stored using [SharedPreferences].
///
/// ### Example Usage:
/// ```dart
/// ThemeSwitcher()
/// ```
///
/// The icon updates dynamically based on the current theme:
/// - Light mode: Displays a moon icon.
/// - Dark mode: Displays a sun icon.
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      icon: Icon(
        themeProvider.themeMode == ThemeMode.light
            ? Icons.nightlight
            : Icons.wb_sunny,
      ),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await themeProvider.switchTheme(prefs); // Updates the theme directly
      },
    );
  }
}
