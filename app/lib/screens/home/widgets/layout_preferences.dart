import 'package:flutter/material.dart';

class LayoutPreferences extends ChangeNotifier {
  bool _compactMode = false;

  bool get compactMode => _compactMode;

  void toggleCompactMode() {
    _compactMode = !_compactMode;
    notifyListeners();
  }
}
