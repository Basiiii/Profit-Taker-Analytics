import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';

/// Builds the content for a card widget that displays time-related data.
///
/// [context] The build context used for widget rendering.
/// [timeValue] The time value to be displayed, representing a time measurement.
/// [timeDifferenceData] A map containing time difference data with keys like
/// 'label', 'bestTime', 'differenceText', and 'isNegative' to represent
/// respective time-related information and whether the difference is negative.
/// [color] The color used for the text of the time value.
Widget buildCardContent(BuildContext context, double timeValue,
    Map<String, dynamic> timeDifferenceData, Color color) {
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
                child: Row(
                  children: [
                    Text(
                      "${timeDifferenceData['label']} ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${timeDifferenceData['bestTime'].toStringAsFixed(3)}s    ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeDifferenceData['differenceText'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: timeDifferenceData['isNegative']
                      ? Colors.green
                      : Colors.red,
                  height: 0,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    ),
  );
}
