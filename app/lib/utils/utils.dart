import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:profit_taker_analyzer/main.dart';

/// Switches the current theme.
///
/// Checks the current theme mode and switches it to the other mode.
/// Then, it saves the new theme mode to the shared preferences.
Future<void> switchTheme() async {
  ThemeMode newMode = MyApp.themeNotifier.value == ThemeMode.light
      ? ThemeMode.dark
      : ThemeMode.light;

  MyApp.themeNotifier.value = newMode;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<ThemeMode, String> themeModeMap = {
    ThemeMode.light: 'light',
    ThemeMode.dark: 'dark',
  };
  prefs.setString('themeMode', themeModeMap[newMode]!);
}

/// Launches a URL.
///
/// Parses the provided URL and checks if it can be launched.
/// If it can be launched, it does so. Otherwise, it throws an error.
void launchURL(String url) async {
  final Uri parsedUrl = Uri.parse(url);
  if (await canLaunchUrl(parsedUrl)) {
    await launchUrl(parsedUrl);
  } else {
    throw 'Could not launch $url';
  }
}

/// Rounds the given [value] to three decimal places.
///
/// This function multiplies the input [value] by 1000, rounds the result to the nearest integer,
/// and then divides the rounded value by 1000 to obtain the rounded result with three decimal places.
///
/// Example:
/// ```dart
/// double originalValue = 3.14159265359;
/// double roundedValue = roundToThreeDecimalPlaces(originalValue);
/// print(roundedValue); // Output: 3.142
/// ```
double roundToThreeDecimalPlaces(double value) {
  return ((value * 1000).round() / 1000);
}

/// Retrieves a numeric value from the provided [jsonData] using the specified [key],
/// rounds it to three decimal places, and returns the rounded value as a formatted string.
///
/// This function assumes that the value associated with the given [key] in [jsonData] is numeric.
/// It casts the value to a double, rounds it to three decimal places using [roundToThreeDecimalPlaces],
/// and then converts the rounded value to a string using [toStringAsFixed].
///
/// Throws an exception if the [key] is not present in [jsonData] or if the value associated with
/// the [key] cannot be cast to a numeric type.
///
/// Example:
/// ```dart
/// Map<String, dynamic> jsonData = {'value': 7.123456789};
/// String roundedValue = getRoundedJsonValueAsString(jsonData, 'value');
/// print(roundedValue); // Output: '7.123'
/// ```
String getRoundedJsonValueAsString(Map<String, dynamic> jsonData, String key) {
  // Retrieve the value, cast it to a double, and round it
  double value = roundToThreeDecimalPlaces((jsonData[key] as num).toDouble());

  // Return the rounded value as a string
  return value.toStringAsFixed(3);
}
