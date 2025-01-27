import 'package:flutter/material.dart';

/// Builds a Row widget with the specified parameters.
///
/// This function creates a Row widget with a label and time. The label is
/// displayed with a font size of 16 and font weight of 400. The time is
/// displayed with a font size of 16, font family 'DMMono', and aligns to
/// the right. The color of the time text is determined by the theme's surface variant.
///
/// ```dart
/// buildRow(context, "Label", "Time");
/// ```
///
/// The above code will produce a Row widget with a label and time. The label
/// will be displayed with a font size of 16 and font weight of 400. The time
/// will be displayed with a font size of 16, font family 'DMMono', and aligns
/// to the right. The color of the time text will be determined by the theme's
/// surface variant.
///
/// Parameters:
/// * [context]: The build context.
/// * [label]: The label to be displayed.
/// * [time]: The time to be displayed.
///
/// Returns:
/// A [Row] widget with the specified parameters.
Widget buildRow(
    BuildContext context, String label, String time, bool isBugged) {
  return Row(
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      Expanded(
        child: Text(
          time,
          style: TextStyle(
              fontSize: 16,
              fontFamily: 'DMMono',
              color: isBugged
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.surfaceContainerHighest),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}
