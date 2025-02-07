import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/get_time_value_color.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/build_card_content.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/build_card_header.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/calculate_time_diff.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/overview/get_card_details.dart';
import 'package:rust_core/rust_core.dart';

/// Builds the overview card widget, displaying various time-related data and other relevant information.
///
/// [index] The index used to determine the specific data for the card (e.g., total times, colors).
/// [context] The build context used for widget rendering and theme access.
/// [screenWidth] The width of the screen, used to adjust the card width responsively.
/// [totalTimes] The total times model containing data for the current phase.
/// [isCompact] A boolean flag that determines if the card should be displayed in a compact format.
/// [bestValues] A list of best values used to calculate the time difference if available.
/// [isComparingToPB] A boolean flag indicating if the comparison is made to a personal best (PB).
/// [isBuggedRun] A boolean flag indicating whether the run was bugged, which affects the display of certain elements.
/// [isAbortedRun] A boolean flag indicating whether the run was aborted, affecting the display of specific elements.
///
/// Returns a [Widget] representing the overview card, which includes:
/// - A responsive width that adjusts based on the screen size.
/// - A header section showing the title and time value with dynamic styling.
/// - A content section (optional) that displays additional information, such as time differences and color coding.
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
