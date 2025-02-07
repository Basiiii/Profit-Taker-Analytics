// Helper: Build Legs Info
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';
import 'package:rust_core/rust_core.dart';

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
