import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/app_layout.dart';
import 'package:profit_taker_analyzer/constants/preferences/shared_prefs_keys.dart';
import 'package:profit_taker_analyzer/utils/formatting/replace_new_lines.dart';
import 'package:rust_core/rust_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GraphWidget extends StatelessWidget {
  final List<AnalyticsRunTotalTimesModel> runInfo;

  const GraphWidget({super.key, required this.runInfo});

  List<CartesianSeries<AnalyticsRunTotalTimesModel, String>> getGraphSeries(
      BuildContext context) {
    final List<CartesianSeries<AnalyticsRunTotalTimesModel, String>> series =
        [];

    final Map<String, Map<String, dynamic>> seriesConfigs = {
      'total': {
        'color': const Color(0xFF68ADFF),
        'label': 'graph.total',
        'valueMapper': (AnalyticsRunTotalTimesModel run, int index) =>
            run.totalTime,
        'isVisible': true,
      },
      'flight': {
        'color': const Color(0xFFFFB054),
        'label': 'graph.flight',
        'valueMapper': (AnalyticsRunTotalTimesModel run, int index) =>
            run.totalFlightTime,
        'isVisible': true,
      },
      'shield': {
        'color': const Color(0xFF7C8AE7),
        'label': 'graph.shields',
        'valueMapper': (AnalyticsRunTotalTimesModel run, int index) =>
            run.totalShieldTime,
        'isVisible': true,
      },
      'leg': {
        'color': const Color(0xFF59D5D9),
        'label': 'graph.legs',
        'valueMapper': (AnalyticsRunTotalTimesModel run, int index) =>
            run.totalLegTime,
        'isVisible': true,
      },
      'body': {
        'color': const Color(0xFFDB5858),
        'label': 'graph.body',
        'valueMapper': (AnalyticsRunTotalTimesModel run, int index) =>
            run.totalBodyTime,
        'isVisible': true,
      },
      'pylons': {
        'color': const Color(0xFFE888DE),
        'label': 'graph.pylons',
        'valueMapper': (AnalyticsRunTotalTimesModel run, int index) =>
            run.totalPylonTime,
        'isVisible': true,
      },
    };

    for (var entry in seriesConfigs.entries) {
      if (entry.value['isVisible'] as bool) {
        series.add(
          LineSeries<AnalyticsRunTotalTimesModel, String>(
            key: ValueKey(entry.key),
            dataSource: runInfo,
            xValueMapper: (run, _) =>
                runInfo[runInfo.indexOf(run)].runName.isEmpty
                    ? 'Run #${runInfo[runInfo.indexOf(run)].id}'
                    : runInfo[runInfo.indexOf(run)].runName,
            yValueMapper: entry.value['valueMapper']
                as ChartValueMapper<AnalyticsRunTotalTimesModel, num>,
            color: entry.value['color'] as Color,
            markerSettings: const MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              borderColor: Colors.white,
              borderWidth: 2,
            ),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.auto,
            ),
            width: 4,
            legendItemText:
                FlutterI18n.translate(context, entry.value['label'] as String),
            animationDuration: 1500,
            enableTooltip: true,
            onPointTap: (ChartPointDetails details) {
              int index = details.pointIndex!;
              AnalyticsRunTotalTimesModel tappedRun = runInfo[index];

              // Show a dialog with run details
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(tappedRun.runName.isEmpty
                        ? 'Run #${tappedRun.id}'
                        : tappedRun.runName),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment
                              .centerLeft, // Align all text to the left
                          child: Text(
                            '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.total_duration"))}: ${tappedRun.totalTime.toStringAsFixed(3)}s\n'
                            '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.flight_time"))}: ${tappedRun.totalFlightTime.toStringAsFixed(3)}s\n'
                            '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.shield_break"))}: ${tappedRun.totalShieldTime.toStringAsFixed(3)}s\n'
                            '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.leg_break"))}: ${tappedRun.totalLegTime.toStringAsFixed(3)}s\n'
                            '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.body_kill"))}: ${tappedRun.totalBodyTime.toStringAsFixed(3)}s\n'
                            '${replaceNewLines(FlutterI18n.translate(context, "overview_cards.pylon_destruction"))}: ${tappedRun.totalPylonTime.toStringAsFixed(3)}s',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          // Set shared pref for current run ID on home page
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt(
                              SharedPrefsKeys.currentRunId, tappedRun.id);

                          // Attempt to switch tabs to home page
                          AppLayout.globalKey.currentState?.selectTab(0);

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Text(
                          FlutterI18n.translate(context, "common.view"),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          FlutterI18n.translate(context, "common.close"),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      }
    }

    return series;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceBright,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Opacity(
                opacity: runInfo.isNotEmpty ? 1.0 : 0.5,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  primaryYAxis: const NumericAxis(
                    labelFormat: '{value}s',
                  ),
                  title: ChartTitle(
                      text: FlutterI18n.translate(
                          context, "analytics.run_times")),
                  legend: const Legend(isVisible: true),
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true, // Allows pinch zoom
                    enablePanning: true, // Allows dragging (panning)
                    zoomMode: ZoomMode.xy, // Zoom in both X & Y axes
                    enableMouseWheelZooming:
                        true, // Zoom using mouse wheel (desktop)
                  ),
                  series: getGraphSeries(context),
                ),
              ),
              if (runInfo.isEmpty)
                Center(
                  child: Text(
                    FlutterI18n.translate(context, "analytics.no_data"),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
