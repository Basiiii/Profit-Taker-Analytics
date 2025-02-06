import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/analytics/analytics_data.dart';
import 'package:profit_taker_analyzer/utils/text_utils.dart';

Widget buildAverageCards(int index, BuildContext context, double screenWidth,
    List<VoidCallback> onTapCallbacks) {
  // Extra 8 pixels for padding
  // NOTE: I'm not sure why this needs padding and the other doesn't...
  double responsiveCardWidth = screenWidth / 6 - 8;

  // Define a map of index to a map of time thresholds to colors
  Map<int, Map<double, Color>> indexToThresholdColorsMap = {
    0: {
      55.000: const Color(0xFFb33dc6),
      60.000: const Color(0xFF27aeef),
      70.000: const Color(0xFFbdcf32),
      90.000: const Color(0xFFef9b20),
    },
    1: {
      3.500: const Color(0xFFb33dc6),
      4.000: const Color(0xFF27aeef),
      6.000: const Color(0xFFbdcf32),
      8.000: const Color(0xFFef9b20),
    },
    2: {
      7.000: const Color(0xFFb33dc6),
      8.000: const Color(0xFF27aeef),
      10.000: const Color(0xFFbdcf32),
      15.000: const Color(0xFFef9b20),
    },
    3: {
      8.000: const Color(0xFFb33dc6),
      10.000: const Color(0xFF27aeef),
      15.000: const Color(0xFFbdcf32),
      20.000: const Color(0xFFef9b20),
    },
    4: {
      1.300: const Color(0xFFb33dc6),
      1.500: const Color(0xFF27aeef),
      1.800: const Color(0xFFbdcf32),
      2.200: const Color(0xFFef9b20),
    },
    5: {
      16.000: const Color(0xFFb33dc6),
      18.000: const Color(0xFF27aeef),
      23.000: const Color(0xFFbdcf32),
      28.000: const Color(0xFFef9b20),
    },
  };

  // Get the color based on the index and time value
  Color color = Theme.of(context).colorScheme.onSurface; // Default color
  if (indexToThresholdColorsMap.containsKey(index)) {
    Map<double, Color>? thresholdColorsMap = indexToThresholdColorsMap[index];
    double timeValue = double.parse(averageCards[index].time);

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
      color = const Color(0xFFE04343);
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
      onTap: onTapCallbacks[index],
      // () {
      //   // Handle the click event here
      //   print('Card $index was tapped');
      // },
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
                          averageCards[index].time, 32, FontWeight.w600,
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
