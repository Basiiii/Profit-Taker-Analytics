import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/main.dart';
import 'package:profit_taker_analyzer/screens/analytics/analytics_data.dart';
import 'package:profit_taker_analyzer/screens/analytics/analytics_widgets.dart';
// import 'package:profit_taker_analyzer/services/last_runs.dart';
import 'package:profit_taker_analyzer/theme/theme_provider.dart';
import 'package:profit_taker_analyzer/utils/screenshot.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:profit_taker_analyzer/widgets/theme_switcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

typedef ValueMapper = double Function(RunData);

class CustomScrollBehavior extends ScrollBehavior {
  final bool isScrollEnabled;

  const CustomScrollBehavior({required this.isScrollEnabled});

  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return isScrollEnabled
        ? const ClampingScrollPhysics()
        : const NeverScrollableScrollPhysics();
  }
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isTotalTimeVisible = true;
  bool _isFlightTimeVisible = true;
  bool _isShieldTimeVisible = true;
  bool _isLegTimeVisible = true;
  bool _isBodyTimeVisible = true;
  bool _isPylonTimeVisible = true;

  /// A controller for taking screenshots.
  ScreenshotController screenshotController = ScreenshotController();

  void toggleTotalTimeVisibility() {
    setState(() {
      _isTotalTimeVisible = !_isTotalTimeVisible;
    });
  }

  void toggleFlightTimeVisibility() {
    setState(() {
      _isFlightTimeVisible = !_isFlightTimeVisible;
    });
  }

  void toggleShieldTimeVisibility() {
    setState(() {
      _isShieldTimeVisible = !_isShieldTimeVisible;
    });
  }

  void toggleLegTimeVisibility() {
    setState(() {
      _isLegTimeVisible = !_isLegTimeVisible;
    });
  }

  void toggleBodyTimeVisibility() {
    setState(() {
      _isBodyTimeVisible = !_isBodyTimeVisible;
    });
  }

  void togglePylonTimeVisibility() {
    setState(() {
      _isPylonTimeVisible = !_isPylonTimeVisible;
    });
  }

  List<File> allRuns = []; // List of all runs as file objects
  List<String> runFilenames = []; // List to store all run filenames

  List<CartesianSeries<RunData, String>> getGraphSeries() {
    final List<CartesianSeries<RunData, String>> series = [];

    final Map<String, Map<String, dynamic>> seriesConfigs = {
      'total': {
        'color': const Color(0xFF68ADFF),
        'label': 'graph.total',
        'valueMapper': (RunData run) =>
            run.totalTime, // Ensure correct return type
        '_isVisible': _isTotalTimeVisible,
      },
      'flight': {
        'color': const Color(0xFFFFB054),
        'label': 'graph.flight',
        'valueMapper': (RunData run) =>
            run.flightTime, // Ensure correct return type
        '_isVisible': _isFlightTimeVisible,
      },
      'shield': {
        'color': const Color(0xFF7C8AE7),
        'label': 'graph.shields',
        'valueMapper': (RunData run) =>
            run.shieldTime, // Ensure correct return type
        '_isVisible': _isShieldTimeVisible,
      },
      'leg': {
        'color': const Color(0xFF59D5D9),
        'label': 'graph.legs',
        'valueMapper': (RunData run) =>
            run.legTime, // Ensure correct return type
        '_isVisible': _isLegTimeVisible,
      },
      'body': {
        'color': const Color(0xFFDB5858),
        'label': 'graph.body',
        'valueMapper': (RunData run) =>
            run.bodyTime, // Ensure correct return type
        '_isVisible': _isBodyTimeVisible,
      },
      'pylons': {
        'color': const Color(0xFFE888DE),
        'label': 'graph.pylons',
        'valueMapper': (RunData run) =>
            run.pylonTime, // Ensure correct return type
        '_isVisible': _isPylonTimeVisible,
      },
    };

    seriesConfigs.forEach((key, config) {
      if (config['_isVisible'] as bool) {
        final ValueMapper valueMapper = config['valueMapper'] as ValueMapper;

        series.add(
          LineSeries<RunData, String>(
            key: ValueKey(key),
            dataSource: data,
            xValueMapper: (RunData run, _) => run.runName,
            yValueMapper: (RunData run, _) => valueMapper(run),
            color: config['color'] as Color,
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
                FlutterI18n.translate(context, config['label'] as String),
            onPointTap: (ChartPointDetails details) {
              _handlePointTap(details);
            },
          ),
        );
      }
    });

    return series;
  }

  void _handlePointTap(ChartPointDetails details) {
    if (details.pointIndex != null) {
      final int tappedPointIndex = details.pointIndex!;
      final RunData tappedRunData = data[tappedPointIndex];
      final String tappedFileName = tappedRunData.fileName;
      final String tappedRunName = tappedRunData.runName;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(tappedRunName),
            content: Text(
              '${FlutterI18n.translate(context, "graph.view_question")}$tappedRunName${FlutterI18n.translate(context, "graph.after_question")}',
            ),
            actions: <Widget>[
              TextButton(
                child: Text(FlutterI18n.translate(context, "buttons.yes")),
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: this was removed, check it
                  // widget.onSelectHomeTab(
                  //   0,
                  //   findFileNameIndex(runFilenames, tappedFileName),
                  //   fileName: tappedFileName,
                  // );
                },
              ),
              TextButton(
                child: Text(FlutterI18n.translate(context, "buttons.no")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(FlutterI18n.translate(context, "errors.error")),
            content: Text(FlutterI18n.translate(context, "errors.unexpected")),
            actions: <Widget>[
              TextButton(
                child: Text(FlutterI18n.translate(context, "buttons.ok")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Timer? _debounceTimer;

  late ZoomPanBehavior _zoomPanBehavior;
  bool _isControlPressed = false;
  ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
      enablePanning: true,
    );

    _scrollController = ScrollController();

    _focusNode.addListener(_focusNodeListener);
    _focusNode.requestFocus();

    /// Populate lists with run history
    // allRuns = getStoredRuns();
    // getRunFileNames(allRuns, allRuns.length, runFilenames);

    loadData();
  }

  /// Finds the index of a file name in the list of run filenames.
  ///
  /// This function takes a list of file names and a file name, and returns
  /// the index of the file name in the list.
  ///
  /// Parameters:
  ///   - runFilenames: The list of file names.
  ///   - fileName: The file name to find.
  ///
  /// Returns:
  ///   - The index of the file name in the list, or -1 if the file name is not found.
  int findFileNameIndex(List<String> runFilenames, String fileName) {
    return runFilenames.indexOf(fileName);
  }

  void loadData() async {
    try {
      var mainPath = Platform.resolvedExecutable;
      mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
      final dir = Directory("$mainPath\\storage");

      // Ensure the directory exists before proceeding
      if (!await dir.exists()) {
        throw Exception('Directory $dir does not exist');
      }

      await updateAverageCards(averageCards, dir);
      data = await loadAllTotalTimes(dir);

      // Notify the framework to rebuild the UI with the updated averages
      setState(() {});
    } catch (e) {
      // Handle any errors that occurred while loading data
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }
  }

  void _focusNodeListener() {
    if (_focusNode.hasPrimaryFocus) {
      _updateControlKeyState();
    }
  }

  void _updateControlKeyState() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _isControlPressed = HardwareKeyboard.instance.physicalKeysPressed
                .contains(LogicalKeyboardKey.controlLeft) ||
            HardwareKeyboard.instance.physicalKeysPressed
                .contains(LogicalKeyboardKey.controlRight);
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_focusNodeListener);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width -
        (LayoutConstants.totalLeftPaddingHome) -
        13; // 13 pixels to make left side padding the same as the right side

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) {
        // Only handle key down events
        if (event is KeyDownEvent) {
          _updateControlKeyState();
        } else if (event is KeyUpEvent) {
          // Immediately update the state when the key is released
          setState(() {
            _isControlPressed = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          // Update the ScrollPhysics based on whether the Control key is pressed
          physics: CustomScrollBehavior(isScrollEnabled: !_isControlPressed)
              .getScrollPhysics(context),
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.only(left: 60, top: 30, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    titleText('Profit Taker Analytics', 32, FontWeight.bold),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              var scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                              captureScreenshot(screenshotController)
                                  .then((status) {
                                String message =
                                    messages[status] ?? 'Unknown status';
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              });
                            },
                          ),
                          IconButton(
                              onPressed: () {
                                loadData();
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh)),
                          const ThemeSwitcher(),
                        ],
                      ),
                    ),
                  ],
                ),
                titleText(FlutterI18n.translate(context, "analytics.title"), 24,
                    FontWeight.normal),
                const SizedBox(height: 15),
                Screenshot(
                  controller: screenshotController,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: [
                          ...List.generate(
                            6,
                            (index) => buildAverageCards(
                              index,
                              context,
                              screenWidth,
                              [
                                toggleTotalTimeVisibility,
                                toggleFlightTimeVisibility,
                                toggleShieldTimeVisibility,
                                toggleLegTimeVisibility,
                                toggleBodyTimeVisibility,
                                togglePylonTimeVisibility,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width:
                            screenWidth < LayoutConstants.minimumResponsiveWidth
                                ? LayoutConstants.graphCardWidth
                                : screenWidth + 13,
                        height: 400,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceBright,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 10),
                            child: Stack(
                              children: [
                                Opacity(
                                  opacity: data.isNotEmpty ? 1.0 : 0.5,
                                  child: SfCartesianChart(
                                    primaryXAxis: const CategoryAxis(),
                                    primaryYAxis: const NumericAxis(
                                      anchorRangeToVisiblePoints: true,
                                      labelFormat: '{value}s',
                                      minimum: 0,
                                      // maximum: 120,
                                    ),
                                    title: const ChartTitle(text: 'Run Times'),
                                    legend: const Legend(isVisible: true),
                                    zoomPanBehavior: _zoomPanBehavior,
                                    series: getGraphSeries(),
                                  ),
                                ),
                                if (data.isEmpty)
                                  const Center(
                                    child: Text(
                                      'No data available',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
