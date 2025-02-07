import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';
import 'package:rust_core/rust_core.dart';

/// Builds the shields information section for a phase, displaying the status effect icons and their respective shield times.
///
/// [index] The index of the current phase, used to handle specific conditions (e.g., skipping the display for index 1).
/// [phase] The phase data model containing the shield changes for the current phase.
/// [context] The build context used for widget rendering and theme access.
/// [isBuggedRun] A boolean flag indicating whether the run was bugged, which affects the styling of certain elements.
///
/// Returns a [Widget] representing the shields information for the phase, which includes:
/// - A [Wrap] widget to display each shield change with spacing between items.
/// - Each shield change is represented by an [Icon] for the status effect and a [Text] widget showing the shield time.
/// - The shield time is displayed with a fixed precision of three decimal places.
/// - The color of the shield time text may change for specific conditions (e.g., for bugged runs).
Widget buildShieldsInfo(
    int index, PhaseModel phase, BuildContext context, bool isBuggedRun) {
  if (index == 1) return const SizedBox.shrink();

  return Wrap(
    spacing: 20.0,
    runSpacing: 8.0,
    direction: Axis.horizontal,
    children: phase.shieldChanges.map((pair) {
      bool isFirstPairAndIndexThreeAndBuggedRun =
          index == 3 && pair == phase.shieldChanges.first && isBuggedRun;
      return SizedBox(
        width: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(getStatusEffectIcon(pair.statusEffect), size: 13),
            Text(
              pair.shieldTime.toStringAsFixed(3),
              style: TextStyle(
                fontFamily: 'DMMono',
                fontSize: 12,
                color: isFirstPairAndIndexThreeAndBuggedRun
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
