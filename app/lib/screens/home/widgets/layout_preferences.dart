import 'package:flutter/material.dart';

/// A class that manages the layout preferences of the app.
///
/// This class handles whether the app should be in compact mode or not. It provides a method
/// to toggle between these two layout modes. It extends [ChangeNotifier] to notify listeners
/// when the layout preference changes.
///
/// [compactMode] A boolean that represents the current layout mode. If true, the app is in compact mode,
/// otherwise, it is in the default mode.
///
/// Methods:
/// - [toggleCompactMode] Toggles the current layout mode between compact and default modes.
class LayoutPreferences extends ChangeNotifier {
  // The current state of compact mode
  bool _compactMode = false;

  /// Getter for [compactMode], returns the current layout mode state.
  bool get compactMode => _compactMode;

  /// Toggles the compact mode state and notifies listeners.
  ///
  /// This method switches between compact and default layout modes. It calls [notifyListeners]
  /// to update the UI and notify any listeners about the change in layout preference.
  void toggleCompactMode() {
    _compactMode = !_compactMode;
    notifyListeners();
  }
}
