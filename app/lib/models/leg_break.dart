import 'package:flutter/material.dart';

class LegBreak {
  LegPosition legPosition;
  double breakTime;
  int breakOrder;
  final IconData icon;

  LegBreak({
    required this.legPosition,
    required this.breakTime,
    required this.breakOrder,
    required this.icon,
  });

  /// Factory method to create a default shield.
  static LegBreak defaultLegBreak() {
    return LegBreak(
      legPosition: LegPosition.backLeft,
      breakTime: 0.0,
      breakOrder: 0,
      icon: Icons.question_mark,
    );
  }
}

enum LegPosition {
  frontLeft,
  frontRight,
  backRight,
  backLeft,
}
