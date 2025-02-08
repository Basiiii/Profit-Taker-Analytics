import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';
import 'package:rust_core/rust_core.dart';

/// Builds the legs information section for a phase, displaying the leg positions and their respective break times.
///
/// [phase] The phase data model containing the leg breaks information for the current phase.
/// [context] The build context used for widget rendering and theme access.
///
/// Returns a [Widget] representing the legs information for the phase, which includes:
/// - A [Wrap] widget to display each leg break in a horizontal direction with spacing between items.
/// - Each leg break is represented by an [Icon] for the leg position and a [Text] widget showing the break time.
/// - The break time is displayed with a fixed precision of three decimal places.
Widget buildLegsInfo(PhaseModel phase, BuildContext context) {
  return Wrap(
    spacing: 20.0,
    runSpacing: 8.0,
    direction: Axis.horizontal,
    children: phase.legBreaks.map((pair) {
      return SizedBox(
        width: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(getLegPositionIcon(pair.legPosition), size: 8),
            Text(
              pair.legBreakTime.toStringAsFixed(3),
              style: TextStyle(
                fontFamily: 'DMMono',
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
