import 'package:profit_taker_analyzer/constants/app_constants.dart';
import 'package:profit_taker_analyzer/constants/layout_constants.dart';
import 'package:profit_taker_analyzer/screens/home/run_navigator.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/home_header.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/overview/compact_overview_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/overview/overview_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/phases/compact_phase_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/phases/phase_card.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/run_title.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final int? runId; // Optional run ID passed to the constructor.

  const HomeScreen({super.key, this.runId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// A [ScreenshotController] for taking screenshots.
  ScreenshotController screenshotController = ScreenshotController();

  /// A [ValueNotifier] that tracks whether the shortcut is enabled.
  final ValueNotifier<bool> _shortcutEnabled = ValueNotifier<bool>(true);

  final _keyboardListenerFocus = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Compact mode for layout
  bool compactModeEnabled = false;

  /// Track if the drawer is open to disable scroll shortcut
  bool isDrawerOpen = false;

  // Create a RunNavigator instance
  late RunNavigator _runNavigator;

  @override
  void initState() {
    super.initState();

    // Initialize RunNavigator and pass the initial runId
    _runNavigator = RunNavigator();
    _initializeRunNavigator();
  }

  Future<void> _initializeRunNavigator() async {
    final prefs = await SharedPreferences.getInstance();

    // Get runId from widget, SharedPreferences, or default to 1
    int initialRunId = widget.runId ??
        prefs.getInt('currentRunId') ?? // Check shared preferences
        1; // Default as the last resort

    // Initialize the navigator
    await _runNavigator.initialize(initialRunId);

    // Update the shared preferences with the current runId
    await prefs.setInt('currentRunId', initialRunId);

    setState(() {}); // Trigger UI update
  }

  // Navigate to the previous run
  Future<void> onBackButtonPressed() async {
    await _runNavigator.navigateToPreviousRun();
    setState(() {}); // Trigger UI update after data is loaded
  }

  // Navigate to the next run
  Future<void> onForwardButtonPressed() async {
    await _runNavigator.navigateToNextRun();
    setState(() {}); // Trigger UI update after data is loaded
  }

  // Function to handle keyboard arrow key presses
  bool handleArrowKeys(KeyEvent event) {
    if (event is KeyDownEvent && !isDrawerOpen) {
      if (event.logicalKey == upActionKey) {
        onForwardButtonPressed();
        return true;
      } else if (event.logicalKey == downActionKey) {
        onBackButtonPressed();
        return true;
      }
    }
    return true;
  }

  void onToggleCompactMode() {
    setState(() {
      compactModeEnabled = !compactModeEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate available screen width
    double screenWidth = MediaQuery.of(context).size.width -
        (LayoutConstants.totalLeftPaddingHome) -
        13; // 13 pixels to make left side padding the same as the right side

    // Fetch the current run data from RunNavigator
    final currentRunData = _runNavigator.getCurrentRunData();

    // If the current run data is null (still loading), show a loading indicator
    if (currentRunData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Build the overall widget tree
    return KeyboardListener(
      focusNode: _keyboardListenerFocus,
      onKeyEvent: handleArrowKeys,
      child: ValueListenableBuilder<bool>(
        valueListenable: _shortcutEnabled,
        builder: (BuildContext context, bool shortcutEnabled, Widget? child) {
          return Listener(
            onPointerSignal: (PointerSignalEvent event) {
              if (event is PointerScrollEvent && shortcutEnabled) {
                final delta = event.scrollDelta.dy;
                if (delta < 0 && !isDrawerOpen) {
                  // Scrolling up, go forward
                  onForwardButtonPressed();
                } else if (delta > 0 && !isDrawerOpen) {
                  // Scrolling down, go backward
                  onBackButtonPressed();
                }
              }
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              key: _scaffoldKey,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 60, top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header
                      HomeHeader(
                          appName: AppConstants.appName,
                          username: currentRunData.playerName,
                          compactModeEnabled: compactModeEnabled,
                          onBackButtonPressed: onBackButtonPressed,
                          onForwardButtonPressed: onForwardButtonPressed,
                          onToggleCompactMode: onToggleCompactMode,
                          scaffoldKey: _scaffoldKey),
                      // Spacing
                      const SizedBox(height: 25),
                      // Run Title
                      RunTitle(
                        runName: currentRunData.runName,
                        mostRecentRun: true,
                        soloRun: currentRunData.issoloRun,
                        isBuggedRun: currentRunData.isBuggedRun,
                        isAbortedRun: currentRunData.isAbortedRun,
                        players: currentRunData.squadMembers
                            .map((squadMember) => squadMember.playerName)
                            .toList(),
                        currentLocale: Localizations.localeOf(context),
                        screenshotController: screenshotController,
                        errorTitle:
                            FlutterI18n.translate(context, "errors.error"),
                        buggedRunWarningMessage: FlutterI18n.translate(
                            context, "errors.bugged_run_warning"),
                        abortedRunWarningMessage: FlutterI18n.translate(
                            context, "errors.aborted_run_warning"),
                        showRunWarning: (context, isBugged, isAborted,
                            errorTitle, buggedMsg, abortedMsg, dialogFunc) {
                          if (currentRunData.isBuggedRun) {
                            showBuggedRunWarningDialog(
                                context,
                                errorTitle,
                                FlutterI18n.translate(
                                    context, "errors.bugged_run_warning"));
                          }
                          if (currentRunData.isAbortedRun) {
                            showBuggedRunWarningDialog(
                                context,
                                errorTitle,
                                FlutterI18n.translate(
                                    context, "errors.aborted_run_warning"));
                          }
                        },
                      ),
                      // Spacing
                      const SizedBox(height: 15),
                      Screenshot(
                        controller: screenshotController,
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 12.0,
                              runSpacing: 12.0,
                              children: compactModeEnabled
                                  ? [
                                      ...List.generate(
                                          6,
                                          (index) => buildCompactOverviewCard(
                                              index,
                                              context,
                                              screenWidth,
                                              currentRunData.totalTimes)),
                                      ...List.generate(
                                          4,
                                          (index) => buildCompactPhaseCard(
                                              index,
                                              context,
                                              screenWidth,
                                              currentRunData.phases,
                                              currentRunData.isBuggedRun)),
                                    ]
                                  : [
                                      ...List.generate(
                                          6,
                                          (index) => buildOverviewCard(
                                                index,
                                                context,
                                                screenWidth,
                                                currentRunData.totalTimes,
                                                List.filled(6, 0.0),
                                              )),
                                      ...List.generate(
                                          4,
                                          (index) => buildPhaseCard(
                                                index,
                                                context,
                                                screenWidth,
                                                currentRunData.phases,
                                                currentRunData.isBuggedRun,
                                              )),
                                    ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12), // Space between elements
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
