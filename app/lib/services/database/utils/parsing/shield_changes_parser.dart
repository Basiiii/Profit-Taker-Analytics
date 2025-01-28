import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/models/phase.dart';
import 'package:profit_taker_analyzer/models/shield_change.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';

class ShieldChangesParser {
  static void addShieldChange(Phase phase, Map<String, dynamic> row) {
    final shieldTime = row['shield_time'];
    if (shieldTime != null) {
      // Avoid adding duplicate shield changes (same shield time)
      if (!phase.shieldChanges.any((sc) => sc.shieldTime == shieldTime)) {
        phase.shieldChanges.add(
          ShieldChange(
            shieldTime: shieldTime.toDouble(),
            statusEffect: row['status_effect_id']?.toString() ?? '',
            icon: statusEffectIcons[row['status_effect_id']] ??
                Icons.question_mark,
          ),
        );
      }
    }
  }
}
