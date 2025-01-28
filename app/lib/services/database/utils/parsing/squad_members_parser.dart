import 'package:profit_taker_analyzer/models/squad_member.dart';

class SquadMembersParser {
  static List<SquadMember> parse(List<Map<String, dynamic>> queryResult) {
    final squadMembers = <SquadMember>{}; // Set to avoid duplicates
    for (var row in queryResult) {
      if (row['squad_member_name'] != null) {
        squadMembers.add(SquadMember(playerName: row['squad_member_name']));
      }
    }
    return squadMembers.toList();
  }
}
