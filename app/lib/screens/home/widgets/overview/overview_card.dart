import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/models/total_times.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';

Widget buildOverviewCard(int index, BuildContext context, double screenWidth,
    TotalTimes totalTimes, List<double> bestValues) {
  double responsiveCardWidth = screenWidth / 6 - 8;

  // Fetch card details dynamically
  final cardDetails = getCardDetails(index, totalTimes, context);

  // Calculate time differences
  final timeDifferenceData =
      calculateTimeDifference(cardDetails.timeValue, bestValues[index]);

  return Container(
    width: screenWidth < LayoutConstants.minimumResponsiveWidth
        ? LayoutConstants.overviewCardWidth
        : responsiveCardWidth,
    height: 145,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceBright,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildHeader(
            context, cardDetails.color, cardDetails.icon, cardDetails.titleKey),
        buildContent(context, cardDetails.timeValue, timeDifferenceData),
      ],
    ),
  );
}

/// A helper function to build the header row with the icon and title.
Widget buildHeader(
    BuildContext context, Color color, IconData icon, String titleKey) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, left: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 25,
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          FlutterI18n.translate(context, "overview_cards.$titleKey"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.05,
          ),
        ),
      ],
    ),
  );
}

/// A helper function to build the content with time value and differences.
Widget buildContent(
    BuildContext context, double timeValue, Map<String, dynamic> timeData) {
  final themeColor = Theme.of(context).colorScheme.onSurface;

  return Padding(
    padding: const EdgeInsets.only(top: 12, left: 25),
    child: Align(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          generateRichText(context, [
            generateTextSpan(timeValue.toStringAsFixed(3), 32, FontWeight.w600,
                color: themeColor),
            generateTextSpan('s ', 20, FontWeight.w400, color: themeColor),
          ]),
          Row(
            children: [
              Expanded(
                child: Text(
                  timeData['differenceText'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: timeData['isNegative'] ? Colors.green : Colors.red,
                    height: 0,
                  ),
                ),
              ),
              Text(
                timeData['isPB'] ? "PB " : "BEST ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: timeData['isPB'] ? Colors.green : Colors.red,
                ),
              ),
              Text(
                "${timeData['bestTime'].toStringAsFixed(3)}s    ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: timeData['isPB'] ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Fetch card details (color, icon, title, and time value) based on index.
CardDetails getCardDetails(
    int index, TotalTimes totalTimes, BuildContext context) {
  switch (index) {
    case 0:
      return CardDetails(const Color(0xFF68ADFF), Icons.access_time,
          "total_duration", totalTimes.totalTime);
    case 1:
      return CardDetails(const Color(0xFFFFB054), Icons.flight, "flight_time",
          totalTimes.totalFlight);
    case 2:
      return CardDetails(const Color(0xFF7C8AE7), Icons.shield, "shield_break",
          totalTimes.totalShield);
    case 3:
      return CardDetails(const Color(0xFF59D5D9),
          Icons.airline_seat_legroom_extra, "leg_break", totalTimes.totalLeg);
    case 4:
      return CardDetails(const Color(0xFFDB5858), Icons.my_location,
          "body_kill", totalTimes.totalBody);
    case 5:
      return CardDetails(const Color(0xFFE888DE), Icons.workspaces_outline,
          "pylon_destruction", totalTimes.totalPylon);
    default:
      return CardDetails(
          Theme.of(context).colorScheme.onSurface, Icons.error, "unknown", 0.0);
  }
}

/// Calculate time difference, PB status, and text.
Map<String, dynamic> calculateTimeDifference(
    double timeValue, double bestTime) {
  double timeDifference = timeValue - bestTime;
  bool isPB = timeDifference == 0.0;

  return {
    'differenceText': timeDifference.isNegative
        ? timeDifference.toStringAsFixed(3)
        : '+${timeDifference.toStringAsFixed(3)}',
    'isNegative': timeDifference.isNegative,
    'isPB': isPB,
    'bestTime': bestTime,
  };
}

/// A data class to encapsulate card details.
class CardDetails {
  final Color color;
  final IconData icon;
  final String titleKey;
  final double timeValue;

  CardDetails(this.color, this.icon, this.titleKey, this.timeValue);
}
