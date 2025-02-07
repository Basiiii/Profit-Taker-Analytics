import 'package:profit_taker_analyzer/constants/shared_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sets a value to not show updates in shared preferences
Future<void> saveDontShowUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  // Save the keyId of the downActionKey.
  await prefs.setBool(SharedPrefsKeys.showUpdate, false);
}
