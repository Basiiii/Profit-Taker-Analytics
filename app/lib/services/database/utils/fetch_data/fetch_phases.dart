import 'package:profit_taker_analyzer/models/phase.dart';
import 'package:profit_taker_analyzer/services/database/utils/fetch_data/fetch_leg_breaks.dart';
import 'package:profit_taker_analyzer/services/database/utils/fetch_data/fetch_shield_changes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Fetch the phases and related data (shield changes and leg breaks)
Future<List<Phase>> fetchPhases(Database db, int runId) async {
  final result = await db.rawQuery('''
  SELECT 
      p.phase_number,
      p.total_time AS phase_total_time,
      p.total_shield AS phase_total_shield,
      p.total_leg AS phase_total_leg,
      p.total_body_kill AS phase_total_body_kill,
      p.total_pylon AS phase_total_pylon
  FROM 
      phases p
  WHERE 
      p.run_id = ?
  ORDER BY 
      p.phase_number
  ''', [runId]);

  final phases = result
      .map((row) => Phase(
            phaseNumber: row['phase_number'] as int,
            totalTime: (row['phase_total_time'] as num?)?.toDouble() ?? 0.0,
            totalShield: (row['phase_total_shield'] as num?)?.toDouble() ?? 0.0,
            totalLeg: (row['phase_total_leg'] as num?)?.toDouble() ?? 0.0,
            totalBodyKill:
                (row['phase_total_body_kill'] as num?)?.toDouble() ?? 0.0,
            totalPylon: (row['phase_total_pylon'] as num?)?.toDouble() ?? 0.0,
            shieldChanges: [],
            legBreaks: [],
          ))
      .toList();

  // Now, fetch the shield changes and leg breaks for each phase
  for (var phase in phases) {
    phase.shieldChanges =
        await fetchShieldChanges(db, runId, phase.phaseNumber);
    phase.legBreaks = await fetchLegBreaks(db, runId, phase.phaseNumber);
  }

  return phases;
}
