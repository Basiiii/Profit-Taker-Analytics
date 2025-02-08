import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_legs_info.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_shields_info.dart';
import 'package:rust_core/rust_core.dart';

/// Builds the body of the card widget, which contains information about the current phase,
/// including shields and legs details, with appropriate layout and dividers.
///
/// [rows] A list of widgets that represent the rows of data to be displayed on the left side of the card.
/// [phase] The phase data model that contains information for the current phase being displayed.
/// [index] The index used to adjust the layout or behavior of specific data elements.
/// [context] The build context used for widget rendering and theme access.
/// [isBuggedRun] A boolean flag indicating whether the run was bugged, which may affect the display.
///
/// Returns a [Widget] representing the body of the card, including:
/// - A column of rows on the left side.
/// - A vertical divider separating the left and right sections.
/// - A right section displaying the shields and legs information, with conditional spacing for specific indexes.
Widget buildCardBody(List<Widget> rows, PhaseModel phase, int index,
    BuildContext context, bool isBuggedRun) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, left: 20),
    child: IntrinsicHeight(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          const SizedBox(
            width: 30,
            child: VerticalDivider(
              thickness: 2,
              width: 100,
              color: Color(0xFFAFAFAF),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildShieldsInfo(index, phase, context, isBuggedRun),
                  index != 1
                      ? const SizedBox(height: 6)
                      : const SizedBox.shrink(),
                  buildLegsInfo(phase, context),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
