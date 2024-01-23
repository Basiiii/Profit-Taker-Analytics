import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  fontFamily: 'Rubik',
  colorScheme: const ColorScheme(
    primary: Colors.blue,
    secondary: Colors.lightBlueAccent,
    tertiary: Color(0xFF6D6F78),
    surface: Color(0xFFF2F3F5),
    surfaceVariant: Color(0xFFAFAFAF),
    background: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onTertiary: Colors.black,
    onError: Colors.black,
    brightness: Brightness.light,
  ),
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
