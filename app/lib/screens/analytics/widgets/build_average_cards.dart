import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/analytics/utils/average_cards.dart';
import 'package:profit_taker_analyzer/screens/analytics/utils/index_to_threshold_colors_map.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';
import 'package:rust_core/rust_core.dart';

/// Builds an average time card for a specific time type.
///
/// This function generates a card displaying the average time for a given index
/// (such as total time, flight time, shield time, etc.). It also adjusts the
/// color of the card based on thresholds and time value, and uses a responsive
/// width for layout adjustment.
Widget buildAverageCards(int index, BuildContext context, double screenWidth,
    TimeTypeModel averageTimes) {
  double responsiveCardWidth = screenWidth / 6 - 8;

  // Get the color based on the index and time value
  Color color = Theme.of(context).colorScheme.onSurface; // Default color
  double timeValue = 0.0;

  // Assign the correct time value based on the index
  switch (index) {
    case 0:
      timeValue = averageTimes.totalTime;
      break;
    case 1:
      timeValue = averageTimes.flightTime;
      break;
    case 2:
      timeValue = averageTimes.shieldTime;
      break;
    case 3:
      timeValue = averageTimes.legTime;
      break;
    case 4:
      timeValue = averageTimes.bodyTime;
      break;
    case 5:
      timeValue = averageTimes.pylonTime;
      break;
  }

  // Check the thresholds and assign color based on the time value
  if (indexToThresholdColorsMap.containsKey(index)) {
    Map<double, Color>? thresholdColorsMap = indexToThresholdColorsMap[index];

    // Find the highest threshold that the time value is less than
    double? highestThreshold;
    for (var entry in thresholdColorsMap!.entries) {
      if (timeValue < entry.key) {
        highestThreshold = entry.key;
        break;
      }
    }

    // If the time value is greater than the highest threshold, use the specified color
    if (highestThreshold == null || timeValue >= highestThreshold) {
      color =
          const Color(0xFFE04343); // Default color if no threshold is matched
    } else {
      color = thresholdColorsMap[highestThreshold] ??
          color; // Use the color if available, otherwise fallback to default
    }
  }

  return Material(
    color: Theme.of(context).colorScheme.surfaceBright,
    borderRadius: BorderRadius.circular(10),
    clipBehavior: Clip.antiAlias, // Ensure the splash is clipped to the shape
    child: InkWell(
      // onTap: onTapCallbacks[index], // Call the corresponding callback
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: screenWidth < LayoutConstants.minimumResponsiveWidth
            ? LayoutConstants.overviewCardWidth
            : responsiveCardWidth,
        height: 135,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: averageCards[index].color,
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(averageCards[index].icon,
                              size: 25,
                              color:
                                  Theme.of(context).colorScheme.surfaceBright)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            FlutterI18n.translate(context,
                                "average_cards.${averageCards[index].title}"),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 25),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    generateRichText(context, [
                      generateTextSpan(
                          timeValue.toStringAsFixed(3), 32, FontWeight.w600,
                          color: color),
                      generateTextSpan('s ', 20, FontWeight.w400, color: color),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
