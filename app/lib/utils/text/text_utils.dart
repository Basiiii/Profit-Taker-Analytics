import 'package:flutter/material.dart';

/// Builds a large title-style [Text] widget.
///
/// This function creates a bold, 32px title text using the 'Poppins' font.
/// The text overflow behavior can be customized using the [overflow] parameter.
///
/// ```dart
/// buildTitle("Hello World", overflow: TextOverflow.ellipsis);
/// ```
///
/// - [text]: The title text to display.
/// - [overflow]: How text should behave when it overflows. Defaults to [TextOverflow.clip].
///
/// Returns a [Text] widget styled as a large title.
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

/// Builds a subtitle-style [Text] widget.
///
/// This function creates a 24px normal-weight text using the 'Poppins' font.
/// The text overflow behavior can be customized using the [overflow] parameter.
///
/// ```dart
/// buildSubtitle("Subtitle Example", overflow: TextOverflow.fade);
/// ```
///
/// - [text]: The subtitle text to display.
/// - [overflow]: How text should behave when it overflows. Defaults to [TextOverflow.clip].
///
/// Returns a [Text] widget styled as a subtitle.
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

/// Builds a small title-style [Text] widget.
///
/// This function creates a medium-weight, 20px text using the 'Poppins' font.
/// The text overflow behavior can be customized using the [overflow] parameter.
///
/// ```dart
/// buildSmallTitle("Small Title", overflow: TextOverflow.ellipsis);
/// ```
///
/// - [text]: The small title text to display.
/// - [overflow]: How text should behave when it overflows. Defaults to [TextOverflow.clip].
///
/// Returns a [Text] widget styled as a small title.
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

/// Generates a styled [TextSpan] with the specified properties.
///
/// This function creates a [TextSpan] with the given [text], [fontSize],
/// [fontWeight], and [color]. The 'Rubik' font family is used for styling.
///
/// ```dart
/// generateTextSpan("Highlighted Text", 18.0, FontWeight.w600, color: Colors.blue);
/// ```
///
/// - [text]: The text content of the span.
/// - [fontSize]: The size of the text.
/// - [fontWeight]: The weight of the text (e.g., bold, normal).
/// - [color]: The color of the text (required).
///
/// Returns a [TextSpan] with the specified styling.
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

/// Generates a [RichText] widget containing multiple [TextSpan] elements.
///
/// This function creates a `RichText` widget, allowing different text styles
/// within a single block of text. It uses the default text style of the provided [context].
///
/// ```dart
/// generateRichText(context, [
///   generateTextSpan("Bold", 16, FontWeight.bold, color: Colors.black),
///   generateTextSpan(" Normal", 16, FontWeight.normal, color: Colors.grey),
/// ]);
/// ```
///
/// - [context]: The build context, used to obtain the default text style.
/// - [textSpans]: A list of [TextSpan] elements to display.
///
/// Returns a [RichText] widget with the provided text spans.
RichText generateRichText(BuildContext context, List<TextSpan> textSpans) {
  return RichText(
    text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: textSpans,
    ),
  );
}
