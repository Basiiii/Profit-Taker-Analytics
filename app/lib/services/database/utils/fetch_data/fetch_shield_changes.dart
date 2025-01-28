import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/models/shield_change.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Fetch shield changes for a specific phase
Future<List<ShieldChange>> fetchShieldChanges(
    Database db, int runId, int phaseNumber) async {
  final shieldChanges = await db.rawQuery('''
  SELECT shield_time, status_effect_id
  FROM shield_changes
  WHERE run_id = ? AND phase_number = ?
  ORDER BY shield_time;
  ''', [runId, phaseNumber]);

  return shieldChanges
      .map((row) => ShieldChange(
            shieldTime: (row['shield_time'] as num?)?.toDouble() ?? 0.0,
            statusEffect: row['status_effect_id']?.toString() ?? '',
            icon: statusEffectIcons[row['status_effect_id']] ??
                Icons.question_mark,
          ))
      .toList();
}
