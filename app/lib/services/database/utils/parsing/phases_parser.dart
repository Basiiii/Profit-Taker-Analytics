import 'package:profit_taker_analyzer/models/phase.dart';
import 'package:profit_taker_analyzer/services/database/utils/parsing/leg_breaks_parser.dart';
import 'package:profit_taker_analyzer/services/database/utils/parsing/shield_changes_parser.dart';

class PhasesParser {
  static List<Phase> parse(List<Map<String, dynamic>> queryResult) {
    final phaseMap = <int, Phase>{};
    final squadMembersSet = <String>{}; // To store unique squad member names

    for (var row in queryResult) {
      final phaseNumber = row['phase_number'];

      // Add a phase if it doesn't exist yet
      if (!phaseMap.containsKey(phaseNumber)) {
        phaseMap[phaseNumber] = Phase(
          phaseNumber: phaseNumber,
          totalTime: row['phase_total_time']?.toDouble() ?? 0.0,
          totalShield: row['phase_total_shield']?.toDouble() ?? 0.0,
          totalLeg: row['phase_total_leg']?.toDouble() ?? 0.0,
          totalBodyKill: row['phase_total_body_kill']?.toDouble() ?? 0.0,
          totalPylon: row['phase_total_pylon']?.toDouble() ?? 0.0,
          shieldChanges: [],
          legBreaks: [],
        );
      }

      final phase = phaseMap[phaseNumber]!;

      // Handle Squad Members: Only add if it's a new squad member
      final squadMemberName = row['squad_member_name'];
      if (squadMemberName != null &&
          !squadMembersSet.contains(squadMemberName)) {
        squadMembersSet.add(squadMemberName);
      }

      // Add Shield Changes: Avoid duplicates for the same shield time and phase
      ShieldChangesParser.addShieldChange(phase, row);

      // Add Leg Breaks: Avoid duplicates for the same leg position and phase
      LegBreaksParser.addLegBreak(phase, row);
    }

    // Convert the map to a list of phases
    final phasesList = phaseMap.values.toList();

    // Return the parsed phases
    return phasesList;
  }
}
