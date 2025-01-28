import 'package:profit_taker_analyzer/models/leg_break.dart';
import 'package:profit_taker_analyzer/models/phase.dart';
import 'package:profit_taker_analyzer/models/shield_change.dart';
import 'package:profit_taker_analyzer/theme/custom_icons.dart';

/// Represents a collection of phases.
class Phases {
  List<Phase> phases;

  Phases({required this.phases});

  /// Factory method to create an instance with default phases filled with placeholder data.
  static Phases defaultPhases() {
    return Phases(
      phases: [
        Phase(
          phaseNumber: 1,
          totalTime: 0.0, // Default time is 0
          totalShield: 0,
          totalLeg: 0,
          totalBodyKill: 0,
          totalPylon: 0,
          shieldChanges: [
            ShieldChange(
                shieldTime: 0.0,
                statusEffect: "impact",
                icon: CustomIcons.impact),
            ShieldChange(
                shieldTime: 0.0,
                statusEffect: "impact",
                icon: CustomIcons.impact),
            ShieldChange(
                shieldTime: 0.0,
                statusEffect: "impact",
                icon: CustomIcons.impact),
            ShieldChange(
                shieldTime: 0.0,
                statusEffect: "impact",
                icon: CustomIcons.impact),
          ],
          legBreaks: [
            LegBreak(
                legPosition: LegPosition.frontLeft,
                breakTime: 0.0,
                breakOrder: 1,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.frontRight,
                breakTime: 0.0,
                breakOrder: 2,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.backLeft,
                breakTime: 0.0,
                breakOrder: 3,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.backRight,
                breakTime: 0.0,
                breakOrder: 4,
                icon: CustomIcons.bl),
          ],
        ),
        Phase(
          phaseNumber: 2,
          totalTime: 0.0, // Default time is 0
          totalShield: 0,
          totalLeg: 0,
          totalBodyKill: 0,
          totalPylon: 0,
          shieldChanges: [],
          legBreaks: [
            LegBreak(
                legPosition: LegPosition.frontLeft,
                breakTime: 0.0,
                breakOrder: 1,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.frontRight,
                breakTime: 0.0,
                breakOrder: 2,
                icon: CustomIcons.bl),
          ],
        ),
        Phase(
          phaseNumber: 3,
          totalTime: 0.0, // Default time is 0
          totalShield: 0,
          totalLeg: 0,
          totalBodyKill: 0,
          totalPylon: 0,
          shieldChanges: [
            ShieldChange(
                shieldTime: 0.0,
                statusEffect: "impact",
                icon: CustomIcons.impact),
            ShieldChange(
                shieldTime: 0.0,
                statusEffect: "impact",
                icon: CustomIcons.impact),
          ],
          legBreaks: [
            LegBreak(
                legPosition: LegPosition.frontLeft,
                breakTime: 0.0,
                breakOrder: 1,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.frontRight,
                breakTime: 0.0,
                breakOrder: 2,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.backLeft,
                breakTime: 0.0,
                breakOrder: 3,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.backRight,
                breakTime: 0.0,
                breakOrder: 4,
                icon: CustomIcons.bl),
          ],
        ),
        Phase(
          phaseNumber: 4,
          totalTime: 0.0, // Default time is 0
          totalShield: 0,
          totalLeg: 0,
          totalBodyKill: 0,
          totalPylon: 0,
          shieldChanges: [
            ShieldChange(
                shieldTime: 0.0,
                statusEffect: "impact",
                icon: CustomIcons.impact),
          ],
          legBreaks: [
            LegBreak(
                legPosition: LegPosition.frontLeft,
                breakTime: 0.0,
                breakOrder: 1,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.frontRight,
                breakTime: 0.0,
                breakOrder: 2,
                icon: CustomIcons.bl),
            LegBreak(
                legPosition: LegPosition.backLeft,
                breakTime: 0.0,
                breakOrder: 3,
                icon: CustomIcons.bl),
          ],
        ),
      ],
    );
  }

  /// Adds a new phase to the list.
  void addPhase(Phase phase) {
    phases.add(phase);
  }

  /// Removes a phase from the list by its index.
  void removePhase(int index) {
    if (index >= 0 && index < phases.length) {
      phases.removeAt(index);
    }
  }

  /// Gets a phase by its index.
  Phase? getPhase(int index) {
    if (index >= 0 && index < phases.length) {
      return phases[index];
    }
    return null; // Return null if index is out of range
  }

  /// Returns the total number of phases.
  int get phaseCount => phases.length;
}
