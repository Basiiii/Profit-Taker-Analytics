import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/standard_view/overview_card.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:rust_core/rust_core.dart';

/// Builds and returns a compact card widget for displaying overview information.
Widget buildCompactOverviewCard(int index, BuildContext context,
    double screenWidth, TotalTimesModel totalTimes) {
  // Keep width calculation consistent
  double responsiveCardWidth =
      screenWidth / 6 - 8; // This remains the same as the old code

  // Fetch card details dynamically
  final cardDetails = getCompactCardDetails(index, totalTimes, context);

  // Determine the color for the time value based on thresholds
  Color color = Theme.of(context).colorScheme.onSurface;

  if (index == 0) {
    double timeValue = cardDetails.timeValue;

    if (timeValue < 52.000) {
      color = const Color(0xFFb33dc6);
    } else if (timeValue < 60.000) {
      color = const Color(0xFF27aeef);
    } else if (timeValue < 80.000) {
      color = const Color(0xFFbdcf32);
    } else if (timeValue < 120.000) {
      color = const Color(0xFF35967D);
    } else if (timeValue > 120.000) {
      color = const Color(0xFFef9b20);
    }
  } else if (index == 2 || index == 4 || index == 5) {
    color = Theme.of(context).colorScheme.error;
  }

  // Adjust the card layout to ensure the same responsiveness
  return Container(
    width: screenWidth < LayoutConstants.minimumResponsiveWidth
        ? LayoutConstants
            .overviewCardWidth // Shrink when width is below threshold
        : responsiveCardWidth, // Same width as above when screen is wider
    height: 66, // Keep the fixed height from the old code
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 20),
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
                          color: cardDetails.color,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(cardDetails.icon,
                          size: 25,
                          color: Theme.of(context).colorScheme.surfaceBright)),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      generateRichText(context, [
                        generateTextSpan(
                            cardDetails.timeValue.toStringAsFixed(2),
                            32,
                            FontWeight.w600,
                            color: color),
                        generateTextSpan('s ', 20, FontWeight.w400,
                            color: color),
                      ]),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Fetch card details (color, icon, title, and time value) based on index.
CardDetails getCompactCardDetails(
    int index, TotalTimesModel totalTimes, BuildContext context) {
  switch (index) {
    case 0:
      return CardDetails(
        const Color(0xFF68ADFF),
        Icons.access_time,
        FlutterI18n.translate(context, "compact_overview.total_duration"),
        totalTimes.totalDuration,
      );
    case 1:
      return CardDetails(
        const Color(0xFFFFB054),
        Icons.flight,
        FlutterI18n.translate(context, "compact_overview.flight_time"),
        totalTimes.totalFlightTime,
      );
    case 2:
      return CardDetails(
        const Color(0xFF7C8AE7),
        Icons.shield,
        FlutterI18n.translate(context, "compact_overview.shield_break"),
        totalTimes.totalShieldTime,
      );
    case 3:
      return CardDetails(
        const Color(0xFF59D5D9),
        Icons.airline_seat_legroom_extra,
        FlutterI18n.translate(context, "compact_overview.leg_break"),
        totalTimes.totalLegTime,
      );
    case 4:
      return CardDetails(
        const Color(0xFFDB5858),
        Icons.my_location,
        FlutterI18n.translate(context, "compact_overview.body_kill"),
        totalTimes.totalBodyTime,
      );
    case 5:
      return CardDetails(
        const Color(0xFFE888DE),
        Icons.workspaces_outline,
        FlutterI18n.translate(context, "compact_overview.pylon_destruction"),
        totalTimes.totalPylonTime,
      );
    default:
      return CardDetails(
        Theme.of(context).colorScheme.onSurface,
        Icons.error,
        FlutterI18n.translate(context, "compact_overview.unknown"),
        0.0,
      );
  }
}
