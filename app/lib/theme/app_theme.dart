import 'package:flutter/material.dart';

/// The light theme for the application.
///
/// This theme provides a set of visual properties for the light mode of the app,
/// including colors, fonts, and brightness settings.
final ThemeData lightTheme = ThemeData(
  fontFamily: 'Rubik',
  colorScheme: const ColorScheme(
    primary: Colors.blue,
    secondary: Colors.lightBlueAccent,
    tertiary: Color(0xFF6D6F78),
    surface: Colors.white,
    surfaceVariant: Color(0xFFAFAFAF),
    background: Color(0xFFF2F3F5),
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onTertiary: Colors.black,
    onError: Colors.black,
    brightness: Brightness.light,
    surfaceTint: Color(0xFFF2F3F5),
  ),
);

/// The dark theme for the application.
///
/// This theme provides a set of visual properties for the dark mode of the app,
/// including colors, fonts, and brightness settings.
final ThemeData darkTheme = ThemeData(
  fontFamily: 'Rubik',
  colorScheme: const ColorScheme(
    primary: Color(0xFF86BCFC),
    secondary: Colors.lightBlueAccent,
    tertiary: Colors.white,
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFFAFAFAF),
    background: Color(0xFF121212),
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onTertiary: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
    surfaceTint: Color(0xFF121212),
  ),
);
