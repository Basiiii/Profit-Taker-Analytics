import 'package:flutter/material.dart';

/// Represents a shield object in a phase.
class ShieldChange {
  double shieldTime;
  String statusEffect;
  final IconData icon;

  ShieldChange({
    required this.shieldTime,
    required this.statusEffect,
    required this.icon,
  });

  /// Factory method to create a default shield.
  static ShieldChange defaultShieldChange() {
    return ShieldChange(
      shieldTime: 0.0,
      statusEffect: '',
      icon: Icons.question_mark,
    );
  }
}
