import 'package:flutter/material.dart';

// TODO: document
Text buildTitle(String text, {TextOverflow overflow = TextOverflow.clip}) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    ),
    overflow: overflow,
  );
}

// TODO: document
Text buildSubtitle(String text, {TextOverflow overflow = TextOverflow.clip}) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.normal,
      fontFamily: 'Poppins',
    ),
    overflow: overflow,
  );
}

// TODO: document
Text buildSmallTitle(String text, {TextOverflow overflow = TextOverflow.clip}) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
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
