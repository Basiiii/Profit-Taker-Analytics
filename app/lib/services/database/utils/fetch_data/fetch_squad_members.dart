// Fetch squad members for a specific run
import 'package:profit_taker_analyzer/models/squad_member.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<List<SquadMember>> fetchSquadMembers(Database db, int runId) async {
  final result = await db.rawQuery('''
  SELECT member_name
  FROM squad_members
  WHERE run_id = ?
  ''', [runId]);

  return result
      .map((row) => SquadMember(playerName: row['member_name'] as String))
      .toList();
}
