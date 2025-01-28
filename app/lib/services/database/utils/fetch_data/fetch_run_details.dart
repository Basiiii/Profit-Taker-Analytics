import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Fetch the basic run details
Future<Map<String, dynamic>?> fetchRunDetails(Database db, int runId) async {
  final result = await db.rawQuery('''
  SELECT 
      r.id AS run_id,
      r.time_stamp,
      r.name AS run_name,
      r.player_name,
      r.bugged_run,
      r.aborted_run,
      r.solo_run,
      r.total_time,
      r.total_flight,
      r.total_shield,
      r.total_leg,
      r.total_body,
      r.total_pylon
  FROM 
      runs r
  WHERE 
      r.id = ?
  ''', [runId]);

  return result.isNotEmpty ? result.first : null;
}
