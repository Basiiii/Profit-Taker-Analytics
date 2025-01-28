import 'package:flutter/services.dart';

typedef KeySetCallback = void Function(LogicalKeyboardKey key);

void startListeningForKeys(KeySetCallback onKeySet) {
  bool keyEventListener(KeyEvent event) {
    if (event is KeyDownEvent) {
      onKeySet(event.logicalKey);
      HardwareKeyboard.instance.removeHandler(keyEventListener);
      return true;
    }
    return false;
  }

  HardwareKeyboard.instance.addHandler(keyEventListener);
}
