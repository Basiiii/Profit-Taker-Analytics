import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/models/leg_break.dart';
import 'package:profit_taker_analyzer/services/database/database_maps.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Fetch leg breaks for a specific phase
Future<List<LegBreak>> fetchLegBreaks(
    Database db, int runId, int phaseNumber) async {
  final legBreaks = await db.rawQuery('''
  SELECT leg_position, break_time, break_order
  FROM leg_breaks
  WHERE run_id = ? AND phase_number = ?
  ORDER BY leg_position;
  ''', [runId, phaseNumber]);

  return legBreaks
      .map((row) => LegBreak(
            legPosition: LegPosition.values[(row['leg_position'] as int?) ?? 0],
            breakTime: (row['break_time'] as num?)?.toDouble() ?? 0.0,
            breakOrder: row['break_order'] as int,
            icon: legPositionIcons[
                    LegPosition.values[(row['leg_position'] as int?) ?? 0]] ??
                Icons.question_mark,
          ))
      .toList();
}
