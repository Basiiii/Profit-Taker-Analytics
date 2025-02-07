// Helper: Generate Phase Rows
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/utils/build_row.dart';

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
