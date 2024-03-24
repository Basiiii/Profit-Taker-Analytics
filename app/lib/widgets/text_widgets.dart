import 'package:flutter/material.dart';

/// Creates a styled text widget.
///
/// This function generates a Text widget with the specified [text], [fontSize]
/// and [weight]. The font family used is 'Poppins'. Additionally, it supports
/// text overflow behavior, which can be specified using the [overflow] parameter.
///
/// ```dart
/// titleText("Hello World", 20.0, FontWeight.bold, overflow: TextOverflow.ellipsis);
/// ```
///
/// The above code will produce a bold text with the text "Hello World" and
/// font size 20.0. If the text is too long to fit within its container, it will
/// be truncated and an ellipsis (...) will be displayed at the end.
///
/// Parameters:
/// * [text]: The text to be displayed.
/// * [fontSize]: The size of the font.
/// * [weight]: The weight of the font.
/// * [overflow]: The text overflow behavior. Defaults to [TextOverflow.clip].
///   - [TextOverflow.clip]: Clips the overflowing text.
///   - [TextOverflow.fade]: Fades the overflowing text.
///   - [TextOverflow.ellipsis]: Displays an ellipsis to indicate that the text
///     has been truncated.
///
/// Returns:
/// A [Text] widget with the specified parameters.
Text titleText(String text, double fontSize, FontWeight weight,
    {TextOverflow overflow = TextOverflow.clip}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: weight,
      fontFamily: 'Poppins',
    ),
    overflow: overflow,
  );
}

/// Generates a TextSpan with the specified parameters.
///
/// This function creates a TextSpan widget with the provided [text], [fontSize],
/// [fontWeight], and [color]. The font family used is 'Rubik'.
///
/// ```dart
/// generateTextSpan("Hello World", 20.0, FontWeight.bold, color: Colors.red);
/// ```
///
/// The above code will produce a TextSpan with the text "Hello World", font size
/// 20.0, bold weight, and red color.
///
/// Parameters:
/// * [text]: The text to be displayed.
/// * [fontSize]: The size of the font.
/// * [fontWeight]: The weight of the font.
/// * [color]: The color of the text.
///
/// Returns:
/// A [TextSpan] widget with the specified parameters.
TextSpan generateTextSpan(String text, double fontSize, FontWeight fontWeight,
    {required Color color}) {
  return TextSpan(
    text: text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: 'Rubik',
      color: color,
    ),
  );
}

/// Generates a RichText widget with the specified parameters.
///
/// This function creates a RichText widget with a list of TextSpan children.
/// The default text style of the current context is used for the TextSpan.
///
/// ```dart
/// generateRichText(context, [TextSpan1, TextSpan2]);
/// ```
///
/// The above code will produce a RichText widget with two TextSpan children.
/// The text style of these children will be the default text style of the current context.
///
/// Parameters:
/// * [context]: The build context.
/// * [textSpans]: A list of TextSpan children.
///
/// Returns:
/// A [RichText] widget with the specified parameters.
RichText generateRichText(BuildContext context, List<TextSpan> textSpans) {
  return RichText(
    text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: textSpans,
    ),
  );
}
