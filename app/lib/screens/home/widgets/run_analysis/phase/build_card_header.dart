// Helper: Build Card Header
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';
import 'package:rust_core/rust_core.dart';

Widget buildCardHeader(PhaseModel phase, BuildContext context, int index,
    List<PhaseModel> phases, double flightTime) {
  double totalTimeUpUntilNow = flightTime;

  for (int i = 0; i <= index; i++) {
    totalTimeUpUntilNow += phases[i].totalTime;
  }

  return Padding(
    padding: const EdgeInsets.only(top: 10, left: 20, right: 10),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Text(
            FlutterI18n.translate(
                context, "phase_cards.phase_${phase.phaseNumber}"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              children: <Widget>[
                generateRichText(
                  context,
                  [
                    generateTextSpan(
                      phase.totalTime.toStringAsFixed(3),
                      16,
                      FontWeight.w400,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    generateTextSpan(
                      's / ',
                      16,
                      FontWeight.w400,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    generateTextSpan(totalTimeUpUntilNow.toStringAsFixed(3), 20,
                        FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface),
                    generateTextSpan('s ', 20, FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
