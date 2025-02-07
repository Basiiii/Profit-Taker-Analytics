import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';

/// A widget that displays a subtitle text in the header.
///
/// This widget wraps the given [text] using the [buildSubtitle] function,
/// which applies a predefined subtitle style.
///
/// ### Example Usage:
/// ```dart
/// HeaderSubtitle(text: "Dashboard Overview")
/// ```
///
/// #### Parameters:
/// - `text`: The subtitle text to be displayed.
class HeaderSubtitle extends StatelessWidget {
  final String text;

  const HeaderSubtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return buildSubtitle(text);
  }
}
