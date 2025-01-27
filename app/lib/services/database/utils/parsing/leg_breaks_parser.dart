import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/models/leg_break.dart';
import 'package:profit_taker_analyzer/models/phase.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';

class LegBreaksParser {
  static void addLegBreak(Phase phase, Map<String, dynamic> row) {
    if (row['leg_position'] != null) {
      final legPosition = row['leg_position'];
      if (legPosition >= 0 && legPosition < LegPosition.values.length) {
        phase.legBreaks.add(LegBreak(
          legPosition: LegPosition.values[legPosition],
          breakTime: row['break_time']?.toDouble() ?? 0.0,
          breakOrder: row['break_order'],
          icon: legPositionIcons[LegPosition.values[legPosition]] ??
              Icons.question_mark,
        ));
      }
    }
  }
}
