import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A class to manage action keys for navigation.
///
/// This class provides functionality to save and load action keys for navigating through the app,
/// specifically for the up and down keys on the home page. It uses [SharedPreferences] to persist
/// the selected keys across app sessions.
///
/// Instance variables:
/// - [upActionKey]: The key for going forward on the Home page (default is [LogicalKeyboardKey.arrowUp]).
/// - [downActionKey]: The key for going backwards on the Home page (default is [LogicalKeyboardKey.arrowDown]).
///
/// Methods:
/// - [saveKey]: A method to save a [LogicalKeyboardKey] to [SharedPreferences] by its key name.
/// - [loadKey]: A method to load a [LogicalKeyboardKey] from [SharedPreferences] using its key name.
/// - [saveUpActionKey]: A method to save the up action key to [SharedPreferences].
/// - [saveDownActionKey]: A method to save the down action key to [SharedPreferences].
/// - [loadUpActionKey]: A method to load the up action key from [SharedPreferences].
/// - [loadDownActionKey]: A method to load the down action key from [SharedPreferences].
class ActionKeyManager {
  static const String upActionKeyKey = 'upActionKey';
  static const String downActionKeyKey = 'downActionKey';

  /// Key for going forward on Home Page
  static LogicalKeyboardKey upActionKey = LogicalKeyboardKey.arrowUp;

  /// Key for going backwards on Home Page
  static LogicalKeyboardKey downActionKey = LogicalKeyboardKey.arrowDown;

  /// Saves a [LogicalKeyboardKey] to [SharedPreferences] by its key name.
  ///
  /// This method stores the key's [keyId] in [SharedPreferences], allowing it to be persisted across app sessions.
  ///
  /// Parameters:
  /// - [keyName]: The name of the key to save (e.g., 'upActionKey').
  /// - [key]: The [LogicalKeyboardKey] to save.
  ///
  /// Returns:
  /// A [Future<void>] that completes when the key is saved.
  static Future<void> saveKey(String keyName, LogicalKeyboardKey key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyName, key.keyId);
  }

  /// Loads a [LogicalKeyboardKey] from [SharedPreferences] by its key name.
  ///
  /// This method retrieves the key's [keyId] from [SharedPreferences] and returns the corresponding
  /// [LogicalKeyboardKey], if found.
  ///
  /// Parameters:
  /// - [keyName]: The name of the key to load (e.g., 'upActionKey').
  ///
  /// Returns:
  /// A [Future<LogicalKeyboardKey?>] that completes with the loaded key, or null if no key is found.
  static Future<LogicalKeyboardKey?> loadKey(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    int? keyId = prefs.getInt(keyName);
    if (keyId != null) {
      return LogicalKeyboardKey.findKeyByKeyId(keyId);
    }
    return null;
  }

  /// Saves the up action key to [SharedPreferences].
  ///
  /// This method saves the currently set up action key ([upActionKey]) to [SharedPreferences].
  ///
  /// Returns:
  /// A [Future<void>] that completes when the key is saved.
  static Future<void> saveUpActionKey() async {
    await saveKey(upActionKeyKey, upActionKey);
  }

  /// Saves the down action key to [SharedPreferences].
  ///
  /// This method saves the currently set down action key ([downActionKey]) to [SharedPreferences].
  ///
  /// Returns:
  /// A [Future<void>] that completes when the key is saved.
  static Future<void> saveDownActionKey() async {
    await saveKey(downActionKeyKey, downActionKey);
  }

  /// Loads the up action key from [SharedPreferences].
  ///
  /// This method retrieves the up action key from [SharedPreferences], if it has been saved previously.
  ///
  /// Returns:
  /// A [Future<LogicalKeyboardKey?>] that completes with the loaded up action key, or null if not found.
  static Future<LogicalKeyboardKey?> loadUpActionKey() async {
    return await loadKey(upActionKeyKey);
  }

  /// Loads the down action key from [SharedPreferences].
  ///
  /// This method retrieves the down action key from [SharedPreferences], if it has been saved previously.
  ///
  /// Returns:
  /// A [Future<LogicalKeyboardKey?>] that completes with the loaded down action key, or null if not found.
  static Future<LogicalKeyboardKey?> loadDownActionKey() async {
    return await loadKey(downActionKeyKey);
  }
}
