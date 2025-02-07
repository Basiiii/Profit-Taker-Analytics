// Helper: Build Card Body
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_legs_info.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_analysis/phase/build_shields_info.dart';
import 'package:rust_core/rust_core.dart';

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
