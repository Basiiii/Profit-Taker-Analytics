import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:rust_core/rust_core.dart';

Widget buildOverviewCard(int index, BuildContext context, double screenWidth,
    TotalTimesModel totalTimes, List<double> bestValues, bool isComparingToPB, bool isBuggedRun, bool isAbortedRun) {
  double responsiveCardWidth = screenWidth / 6 - 8;

  // Fetch card details dynamically
  final cardDetails = getCardDetails(index, totalTimes, context);

  // Calculate time differences
  final timeDifferenceData = calculateTimeDifference(
      cardDetails.timeValue, bestValues[index], isComparingToPB);

  // Determine the color for the time value based on thresholds
  Color color = Theme.of(context).colorScheme.onSurface;

  if (index == 0) {
    double timeValue = cardDetails.timeValue;

    if (isAbortedRun == false) {
      if (timeValue < 49.000) {
        color = const Color(0xFFFD2881);
      } else if (timeValue < 50.000) {
        color = const Color(0xFFC144D5);
      } else if (timeValue < 52.000) {
        color = const Color(0xFF9D5DF5);
      } else if (timeValue < 60.000) {
        color = const Color(0xFF27aeef);
      } else if (timeValue < 80.000) {
        color = const Color(0xFF35967D);
      } else if (timeValue < 120.000) {
        color = const Color(0xFF6fc144);
      } else if (timeValue < 180.000) {
        color = const Color(0xFFbdcf32);
      } else if (timeValue > 180.000) {
        color = const Color(0xFFef9b20);
      }
    }
  } else if ((index == 2 || index == 5) && isBuggedRun)  {
    color = Theme.of(context).colorScheme.error;
  }

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
        buildContent(context, cardDetails.timeValue, timeDifferenceData, color),
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
    BuildContext context, double timeValue, Map<String, dynamic> timeData, Color color) {
  //final themeColor = Theme.of(context).colorScheme.onSurface;

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
                color: color),
            generateTextSpan('s ', 20, FontWeight.w400, color: color),
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
                timeData['isPB'] ? "PB " : "${timeData['label']} ",
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
    int index, TotalTimesModel totalTimes, BuildContext context) {
  switch (index) {
    case 0:
      return CardDetails(const Color(0xFF68ADFF), Icons.access_time,
          "total_duration", totalTimes.totalDuration);
    case 1:
      return CardDetails(const Color(0xFFFFB054), Icons.flight, "flight_time",
          totalTimes.totalFlightTime);
    case 2:
      return CardDetails(const Color(0xFF7C8AE7), Icons.shield, "shield_break",
          totalTimes.totalShieldTime);
    case 3:
      return CardDetails(
          const Color(0xFF59D5D9),
          Icons.airline_seat_legroom_extra,
          "leg_break",
          totalTimes.totalLegTime);
    case 4:
      return CardDetails(const Color(0xFFDB5858), Icons.my_location,
          "body_kill", totalTimes.totalBodyTime);
    case 5:
      return CardDetails(const Color(0xFFE888DE), Icons.workspaces_outline,
          "pylon_destruction", totalTimes.totalPylonTime);
    default:
      return CardDetails(
          Theme.of(context).colorScheme.onSurface, Icons.error, "unknown", 0.0);
  }
}

/// Calculate time difference, PB status, and text.
Map<String, dynamic> calculateTimeDifference(
    double timeValue, double bestTime, bool isComparingToPB) {
  double timeDifference = timeValue - bestTime;
  bool isPB = timeDifference == 0.0;

  return {
    'differenceText': timeDifference.isNegative
        ? timeDifference.toStringAsFixed(3)
        : '+${timeDifference.toStringAsFixed(3)}',
    'isNegative': timeDifference.isNegative,
    'isPB': isPB,
    'bestTime': bestTime,
    'label': isComparingToPB ? "PB" : "SB",
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
