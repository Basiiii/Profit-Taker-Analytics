import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';

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
