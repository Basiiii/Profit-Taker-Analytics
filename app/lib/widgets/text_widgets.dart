import 'package:flutter/material.dart';

/// Creates a styled text widget.
///
/// This function generates a Text widget with the specified [text], [fontSize]
/// and [weight]. The font family used is 'Poppins'.
///
/// ```dart
/// titleText("Hello World", 20.0, FontWeight.bold);
/// ```
///
/// The above code will produce a bold text with the text "Hello World" and
/// font size 20.0.
///
/// Parameters:
/// * [text]: The text to be displayed.
/// * [fontSize]: The size of the font.
/// * [weight]: The weight of the font.
///
/// Returns:
/// A [Text] widget with the specified parameters.
Text titleText(String text, double fontSize, FontWeight weight) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: weight,
      fontFamily: 'Poppins',
    ),
  );
}
