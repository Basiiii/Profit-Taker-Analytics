import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/models/leg_break.dart';
import 'package:profit_taker_analyzer/theme/custom_icons.dart';
import 'package:rust_core/rust_core.dart';

/// A mapping of status effect IDs to their corresponding icons.
///
/// The keys represent the IDs of various status effects, while the values
/// are the icons that visually represent these effects. This is used to
/// display appropriate icons for each status effect throughout the application.
///
/// The mapping includes:
/// - Impact, Puncture, Slash, and other damage types, mapped to custom icons.
/// - Placeholder icons (e.g., `Icons.question_mark`) for effects such as Void, Tau,
///   and True, which currently lack specific icons.
///
/// **Usage**:
/// Use this map to get the icon for a given status effect ID:
/// ```dart
/// Icon(statusEffectIcons[effectId]);
/// ```
const Map<int, IconData> statusEffectIcons = {
  1: CustomIcons.impact,
  2: CustomIcons.puncture,
  3: CustomIcons.slash,
  4: CustomIcons.heat,
  5: CustomIcons.cold,
  6: CustomIcons.electric,
  7: CustomIcons.toxin,
  8: CustomIcons.blast,
  9: CustomIcons.radiation,
  10: CustomIcons.gas,
  11: CustomIcons.magnetic,
  12: CustomIcons.viral,
  13: CustomIcons.corrosive,
  14: Icons.question_mark,
};

IconData getStatusEffectIcon(StatusEffectEnum statusEffect) {
  const Map<StatusEffectEnum, IconData> statusEffectIcons = {
    StatusEffectEnum.impact: CustomIcons.impact,
    StatusEffectEnum.puncture: CustomIcons.puncture,
    StatusEffectEnum.slash: CustomIcons.slash,
    StatusEffectEnum.heat: CustomIcons.heat,
    StatusEffectEnum.cold: CustomIcons.cold,
    StatusEffectEnum.electric: CustomIcons.electric,
    StatusEffectEnum.toxin: CustomIcons.toxin,
    StatusEffectEnum.blast: CustomIcons.blast,
    StatusEffectEnum.radiation: CustomIcons.radiation,
    StatusEffectEnum.gas: CustomIcons.gas,
    StatusEffectEnum.magnetic: CustomIcons.magnetic,
    StatusEffectEnum.viral: CustomIcons.viral,
    StatusEffectEnum.corrosive: CustomIcons.corrosive,
    StatusEffectEnum.noShield:
        Icons.question_mark, // Fallback for unknown cases
  };

  return statusEffectIcons[statusEffect] ?? Icons.help_outline;
}

/// A mapping of leg positions to their corresponding icons.
///
/// This map links specific leg positions (e.g., Front Left, Back Right)
/// to their respective icons for better visual representation in the UI.
///
/// The `LegPosition` enum values are used as keys, and custom icons are used
/// as the values.
///
/// **Usage**:
/// Use this map to get the icon for a given leg position:
/// ```dart
/// Icon(legPositionIcons[legPosition]);
/// ```
///
/// **Example**:
/// - `LegPosition.frontLeft` is represented by `CustomIcons.fl`.
/// - `LegPosition.backRight` is represented by `CustomIcons.br`.
const Map<LegPosition, IconData> legPositionIcons = {
  LegPosition.frontLeft: CustomIcons.fl,
  LegPosition.frontRight: CustomIcons.fr,
  LegPosition.backRight: CustomIcons.br,
  LegPosition.backLeft: CustomIcons.bl,
};

IconData getLegPositionIcon(LegPositionEnum legPosition) {
  const Map<LegPositionEnum, IconData> legPositionIcons = {
    LegPositionEnum.frontLeft: CustomIcons.fl,
    LegPositionEnum.frontRight: CustomIcons.fr,
    LegPositionEnum.backRight: CustomIcons.br,
    LegPositionEnum.backLeft: CustomIcons.bl,
  };

  return legPositionIcons[legPosition] ?? Icons.help_outline;
}
