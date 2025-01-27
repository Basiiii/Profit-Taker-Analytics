import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for going forward on Home Page
LogicalKeyboardKey upActionKey = LogicalKeyboardKey.arrowUp;

/// Key for going backwards on Home Page
LogicalKeyboardKey downActionKey = LogicalKeyboardKey.arrowDown;

Future<void> saveUpActionKey() async {
  final prefs = await SharedPreferences.getInstance();
  // Save the keyId of the upActionKey.
  await prefs.setInt('upActionKey', upActionKey.keyId);
}

Future<void> saveDownActionKey() async {
  final prefs = await SharedPreferences.getInstance();
  // Save the keyId of the downActionKey.
  await prefs.setInt('downActionKey', downActionKey.keyId);
}

// Function to load the upActionKey
Future<LogicalKeyboardKey?> loadUpActionKey() async {
  final prefs = await SharedPreferences.getInstance();
  int? upActionKeyId = prefs.getInt('upActionKey');
  if (upActionKeyId != null) {
    // Use the findKeyByKeyId method to locate the LogicalKeyboardKey by its keyId
    return LogicalKeyboardKey.findKeyByKeyId(upActionKeyId);
  }
  return null;
}

// Function to load the downActionKey
Future<LogicalKeyboardKey?> loadDownActionKey() async {
  final prefs = await SharedPreferences.getInstance();
  int? downActionKeyId = prefs.getInt('downActionKey');
  if (downActionKeyId != null) {
    // Use the findKeyByKeyId method to locate the LogicalKeyboardKey by its keyId
    return LogicalKeyboardKey.findKeyByKeyId(downActionKeyId);
  }
  return null;
}
