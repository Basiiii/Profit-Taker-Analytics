import 'package:flutter/material.dart';

/// A data class that encapsulates the details of a card.
///
/// [color] The background color for the card's icon container.
/// [icon] The icon to be displayed on the card.
/// [titleKey] A key used to retrieve the title or label associated with the card.
/// [timeValue] A time value associated with the card, usually representing a measurement.
class CardDetails {
  final Color color;
  final IconData icon;
  final String titleKey;
  final double timeValue;

  CardDetails(this.color, this.icon, this.titleKey, this.timeValue);
}
