import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';

/// A widget that displays a header title with a predefined style.
///
/// This widget uses the [buildTitle] function to format the given [title]
/// with a default font size of `32` and a bold font weight.
///
/// ### Example Usage:
/// ```dart
/// HeaderTitle(title: "Dashboard")
/// ```
///
/// #### Parameters:
/// - `title`: The main title text to be displayed.
/// - `fontSize`: (Optional) The size of the font, default is `32`.
/// - `fontWeight`: (Optional) The weight of the font, default is `FontWeight.bold`.
class HeaderTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;

  const HeaderTitle({
    super.key,
    required this.title,
    this.fontSize = 32,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return buildTitle(title);
  }
}
