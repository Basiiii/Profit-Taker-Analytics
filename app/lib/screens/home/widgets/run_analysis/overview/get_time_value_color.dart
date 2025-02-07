import 'package:flutter/material.dart';

/// Determines the color to be used for displaying a time value based on the index, time value, and run status.
///
/// [index] The index used to determine the color scheme for a specific time value.
/// [timeValue] The time value that needs to be color-coded.
/// [isAbortedRun] A boolean indicating whether the run was aborted.
/// [isBuggedRun] A boolean indicating whether the run was bugged.
/// [context] The build context used for accessing theme and color scheme.
///
/// Returns the [Color] that corresponds to the time value based on the conditions:
/// - For specific index values (like 0), time ranges are assigned different colors.
/// - For bugged runs (index 2 or 5), an error color is applied.
Color getTimeValueColor(int index, double timeValue, bool isAbortedRun,
    bool isBuggedRun, BuildContext context) {
  Color color = Theme.of(context).colorScheme.onSurface;

  if (index == 0 && !isAbortedRun) {
    if (timeValue < 49.000) {
      color = const Color(0xFFFD2881);
    } else if (timeValue < 50.000) {
      color = const Color(0xFFC144D5);
    } else if (timeValue < 52.000) {
      color = const Color(0xFF9D5DF5);
    } else if (timeValue < 60.000) {
      color = const Color(0xFF27aeef);
    } else if (timeValue < 80.000) {
      color = const Color(0xFF35967D);
    } else if (timeValue < 120.000) {
      color = const Color(0xFF6fc144);
    } else if (timeValue < 180.000) {
      color = const Color(0xFFbdcf32);
    } else if (timeValue > 180.000) {
      color = const Color(0xFFef9b20);
    }
  } else if ((index == 2 || index == 5) && isBuggedRun) {
    color = Theme.of(context).colorScheme.error;
  }

  return color;
}
