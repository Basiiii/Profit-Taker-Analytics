import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.lightBlue,
  brightness: Brightness.light,
);

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
  ),
);
