import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/layout/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/analytics/widgets/header.dart';
import 'package:profit_taker_analyzer/screens/analytics/widgets/main_content.dart';
import 'package:profit_taker_analyzer/screens/analytics/widgets/subtitle.dart';
import 'package:rust_core/rust_core.dart';
import 'package:screenshot/screenshot.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  ScrollController _scrollController = ScrollController();
  ScreenshotController screenshotController = ScreenshotController();

  Timer? _debounceTimer;
  TimeTypeModel? _averageTimes; // Store the fetched average times
  List<AnalyticsRunTotalTimesModel> _runTimes = [];

  // Boolean variables to control visibility of different graph series
  bool isTotalTimeVisible = true;
  bool isFlightTimeVisible = true;
  bool isShieldTimeVisible = true;
  bool isLegTimeVisible = true;
  bool isBodyTimeVisible = true;
  bool isPylonTimeVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    fetchAverageData();
    fetchRunTimes();
  }

  // Fetch average times from the Rust backend
  void fetchAverageData() async {
    try {
      final data = getAverageTimes();
      setState(() {
        _averageTimes = data; // Update the state with fetched data
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }
  }

  void fetchRunTimes() async {
    try {
      final runs = getAnalyticsRuns(limit: 50);
      setState(() {
        _runTimes = runs;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching run times: $e');
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width -
        (LayoutConstants.totalLeftPaddingHome) -
        13; // 13 pixels to make left side padding the same as the right side

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(left: 60, top: 30, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnalyticsHeader(
                screenshotController: screenshotController,
                fetchAverageData: fetchAverageData,
              ),
              const AnalyticsSubTitle(),
              AnalyticsMainContent(
                screenWidth: screenWidth,
                screenshotController: screenshotController,
                averageTimes: _averageTimes,
                runTimes: _runTimes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
