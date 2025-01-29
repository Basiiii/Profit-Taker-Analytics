import 'package:flutter/services.dart';

/// A callback function type that is triggered when a key is pressed.
typedef KeySetCallback = void Function(LogicalKeyboardKey key);

/// Starts listening for a single key press event and calls the provided callback when a key is pressed.
///
/// This function adds a key event handler to the hardware keyboard and waits for a key press.
/// Once a key is detected, the callback [onKeySet] is triggered with the pressed [LogicalKeyboardKey].
/// The handler is then removed to ensure only a single key press is captured.
///
/// **Parameters:**
/// - [onKeySet]: A callback function that receives the detected [LogicalKeyboardKey].
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
