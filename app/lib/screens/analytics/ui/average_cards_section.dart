import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/analytics/widgets/build_average_cards.dart';
import 'package:rust_core/rust_core.dart'; // Add the import for RustLib

class AverageCardsSection extends StatelessWidget {
  final double screenWidth;
  final TimeTypeModel averageTimes; // Accept the averageTimes parameter

  const AverageCardsSection({
    super.key,
    required this.screenWidth,
    required this.averageTimes, // Pass in the TimeTypeModel
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        ...List.generate(
          6,
          (index) => buildAverageCards(
            index,
            context,
            screenWidth,
            averageTimes,
          ),
        ),
      ],
    );
  }
}
