import 'package:profit_taker_analyzer/models/leg_break.dart';
import 'package:profit_taker_analyzer/models/shield_change.dart';

/// Represents an individual phase within a run.
///
/// A run is divided into multiple phases, each with specific metrics and events.
/// This class encapsulates the details of a single phase, including its number,
/// performance statistics, and lists of significant events like shield changes
/// and leg breaks.
class Phase {
  /// The number of the phase within the run (e.g., Phase 1, Phase 2, etc.).
  int phaseNumber;

  /// The total time taken to complete this phase.
  double totalTime;

  /// The total time spent to destroy the shield during this phase.
  double totalShield;

  /// The total time spent to destroy the legs during this phase.
  double totalLeg;

  /// The total time spent to destroy the body to achieve a kill during this phase.
  double totalBodyKill;

  /// The total time spent destroying pylons during this phase.
  double totalPylon;

  /// A list of shield change events that occurred during this phase.
  List<ShieldChange> shieldChanges;

  /// A list of leg break events that occurred during this phase.
  List<LegBreak> legBreaks;

  /// Creates an instance of [Phase] with specified metrics and event details.
  ///
  /// - [phaseNumber] represents the sequence number of the phase in the run.
  /// - [totalTime] indicates the total time spent in the phase.
  /// - [totalShield] represents the total shield damage inflicted.
  /// - [totalLeg] represents the total damage dealt to legs.
  /// - [totalBodyKill] indicates the total body damage inflicted to achieve a kill.
  /// - [totalPylon] represents the number of pylons activated during this phase.
  /// - [shieldChanges] is a list of shield change events in the phase.
  /// - [legBreaks] is a list of leg break events in the phase.
  Phase({
    required this.phaseNumber,
    required this.totalTime,
    required this.totalShield,
    required this.totalLeg,
    required this.totalBodyKill,
    required this.totalPylon,
    required this.shieldChanges,
    required this.legBreaks,
  });

  /// Factory method to create a default instance of [Phase].
  ///
  /// This is useful for initializing a phase with placeholder values before
  /// populating it with actual data.
  ///
  /// Default values:
  /// - [phaseNumber] is set to `0`, indicating a placeholder phase.
  /// - [totalTime], [totalShield], [totalLeg], [totalBodyKill], and [totalPylon]
  ///   are all set to `0.0`.
  /// - [shieldChanges] and [legBreaks] are initialized as empty lists.
  static Phase defaultPhase() {
    return Phase(
      phaseNumber: 0, // Default phase number
      totalTime: 0.0, // Default total time
      totalShield: 0.0, // Default total shield
      totalLeg: 0.0, // Default total leg
      totalBodyKill: 0.0, // Default total body kill
      totalPylon: 0.0, // Default total pylon
      shieldChanges: [], // Default empty list of shield changes
      legBreaks: [], // Default empty list of leg breaks
    );
  }
}
