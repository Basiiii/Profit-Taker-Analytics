import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
