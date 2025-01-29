import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A class to manage action keys for navigation.
class ActionKeyManager {
  static const String upActionKeyKey = 'upActionKey';
  static const String downActionKeyKey = 'downActionKey';

  /// Key for going forward on Home Page
  static LogicalKeyboardKey upActionKey = LogicalKeyboardKey.arrowUp;

  /// Key for going backwards on Home Page
  static LogicalKeyboardKey downActionKey = LogicalKeyboardKey.arrowDown;

  /// Save a [LogicalKeyboardKey] by its keyId.
  static Future<void> saveKey(String keyName, LogicalKeyboardKey key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyName, key.keyId);
  }

  /// Load a [LogicalKeyboardKey] from its keyId.
  static Future<LogicalKeyboardKey?> loadKey(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    int? keyId = prefs.getInt(keyName);
    if (keyId != null) {
      return LogicalKeyboardKey.findKeyByKeyId(keyId);
    }
    return null;
  }

  /// Save the up action key.
  static Future<void> saveUpActionKey() async {
    await saveKey(upActionKeyKey, upActionKey);
  }

  /// Save the down action key.
  static Future<void> saveDownActionKey() async {
    await saveKey(downActionKeyKey, downActionKey);
  }

  /// Load the up action key.
  static Future<LogicalKeyboardKey?> loadUpActionKey() async {
    return await loadKey(upActionKeyKey);
  }

  /// Load the down action key.
  static Future<LogicalKeyboardKey?> loadDownActionKey() async {
    return await loadKey(downActionKeyKey);
  }
}
