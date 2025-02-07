// Helper: Build Shields Info
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';
import 'package:rust_core/rust_core.dart';

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
