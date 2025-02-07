import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/get_time_value_color.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/build_card_content.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/build_card_header.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/calculate_time_diff.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/get_card_details.dart';
import 'package:rust_core/rust_core.dart';

Widget buildOverviewCard(int index, BuildContext context, double screenWidth,
    TotalTimesModel totalTimes,
    {bool isCompact = false,
    List<double>? bestValues,
    bool isComparingToPB = false,
    bool isBuggedRun = false,
    bool isAbortedRun = false}) {
  double responsiveCardWidth = screenWidth / 6 - 8;
  final cardDetails =
      getCardDetails(index, totalTimes, context, isCompact: isCompact);

  // Calculate time difference if comparing to PB
  Map<String, dynamic> timeDifferenceData = {};
  if (bestValues != null) {
    timeDifferenceData = calculateTimeDifference(
        cardDetails.timeValue, bestValues[index], isComparingToPB);
  }

  // Determine the color for the time value
  Color color = getTimeValueColor(
      index, cardDetails.timeValue, isAbortedRun, isBuggedRun, context);

  return Container(
    width: screenWidth < LayoutConstants.minimumResponsiveWidth
        ? LayoutConstants.overviewCardWidth
        : responsiveCardWidth,
    height: isCompact ? 66 : 145, // Adjust height based on the view
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildCardHeader(
            context,
            cardDetails.color,
            cardDetails.icon,
            isCompact
                ? '${cardDetails.timeValue.toStringAsFixed(3)}s'
                : cardDetails.titleKey,
            isCompact: isCompact,
            textColor: color),
        if (!isCompact)
          buildCardContent(
              context, cardDetails.timeValue, timeDifferenceData, color),
      ],
    ),
  );
}
