import 'package:profit_taker_analyzer/models/phases.dart';
import 'package:profit_taker_analyzer/models/squad_member.dart';
import 'package:profit_taker_analyzer/models/total_times.dart';

/// Represents an individual run and all its associated data.
///
/// This class encapsulates information about a specific run, including
/// metadata (e.g., `runId`, `timeStamp`, and `runName`), player and team
/// details, performance data, and run status.
class Run {
  /// A unique identifier for the run.
  int runId;

  /// The timestamp indicating when the run took place.
  DateTime timeStamp;

  /// The name given to the run (can be customized by the user).
  String runName;

  /// The name of the host player associated with the run.
  String playerName;

  /// Indicates whether the run encountered a bug.
  bool isBuggedRun;

  /// Indicates whether the run was aborted prematurely.
  bool isAbortedRun;

  /// Indicates whether the run was performed solo.
  bool issoloRun;

  /// The total time-related statistics of the run.
  TotalTimes totalTimes;

  /// The phases associated with the run.
  Phases phases;

  /// A list of squad members who participated in the run.
  List<SquadMember> squadMembers;

  /// Creates an instance of [Run] with the specified details.
  ///
  /// All fields are required to ensure the run is initialized with complete data.
  ///
  /// - [runId] is a unique identifier for the run.
  /// - [timeStamp] specifies when the run occurred.
  /// - [runName] is the name or label of the run.
  /// - [playerName] represents the host player.
  /// - [isBuggedRun] indicates if the run was bugged.
  /// - [isAbortedRun] indicates if the run was aborted.
  /// - [issoloRun] indicates if the run was conducted solo.
  /// - [totalTimes] contains the time statistics for the run.
  /// - [phases] details the run's phases.
  /// - [squadMembers] is a list of participants in the run.
  Run({
    required this.runId,
    required this.timeStamp,
    required this.runName,
    required this.playerName,
    required this.isBuggedRun,
    required this.isAbortedRun,
    required this.issoloRun,
    required this.totalTimes,
    required this.phases,
    required this.squadMembers,
  });

  /// Factory method to create a default instance of [Run].
  ///
  /// This is useful for initializing a run object with placeholder values
  /// before populating it with actual data.
  ///
  /// Default values:
  /// - `runId` is set to -1, indicating an invalid or placeholder run.
  /// - `timeStamp` is set to the epoch date (January 1, 1970).
  /// - `runName` and `playerName` are empty strings.
  /// - `isBuggedRun`, `isAbortedRun`, and `issoloRun` are set to `false`.
  /// - `totalTimes` is initialized with its default values.
  /// - `phases` is initialized with its default values.
  /// - `squadMembers` is an empty list.
  factory Run.defaultRun() {
    return Run(
      runId: -1,
      timeStamp: DateTime(0),
      runName: '',
      playerName: '',
      isBuggedRun: false,
      isAbortedRun: false,
      issoloRun: false,
      totalTimes: TotalTimes.defaultTimes(),
      phases: Phases.defaultPhases(),
      squadMembers: [],
    );
  }
}
