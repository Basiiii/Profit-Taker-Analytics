import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/utils/build_row.dart';

/// Generates a list of rows based on the provided index, labels, and overview data.
///
/// [index] The index used to determine the specific layout or condition of the rows to be generated.
/// [labels] A list of labels used as titles for each row.
/// [overviewList] A list containing the overview data corresponding to each label.
/// [isBuggedRun] A boolean flag indicating if the run was bugged, which affects the styling of certain rows.
/// [context] The build context used for widget rendering and theme access.
///
/// Returns a [List<Widget>] containing the generated rows, each created using the [buildRow] function.
/// - The rows are customized based on the [index], with specific handling for indices 1, 2, and 3.
/// - The styling of certain rows may change based on whether the run is bugged (e.g., for index 2 and 3).
List<Widget> generatePhaseRows(
  int index,
  List<String> labels,
  List<String> overviewList,
  bool isBuggedRun,
  BuildContext context,
) {
  List<Widget> rows;

  if (index == 1) {
    rows = labels.sublist(1, 3).asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key + 1], false);
    }).toList();
  } else if (index == 2) {
    rows = labels.asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key],
          entry.key == 3 && isBuggedRun);
    }).toList();
  } else if (index == 3) {
    rows = labels.sublist(0, 3).asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key],
          entry.key == 0 && isBuggedRun);
    }).toList();
  } else {
    rows = labels.asMap().entries.map((entry) {
      return buildRow(context, entry.value, overviewList[entry.key], false);
    }).toList();
  }
  return rows;
}
