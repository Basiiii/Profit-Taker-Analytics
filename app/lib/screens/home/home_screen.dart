import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';
import 'package:profit_taker_analyzer/services/last_runs.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:process_run/shell.dart';

import 'package:profit_taker_analyzer/main.dart';

import 'package:profit_taker_analyzer/constants/constants.dart';

import 'package:profit_taker_analyzer/services/parser.dart';

import 'package:profit_taker_analyzer/utils/utils.dart';
import 'package:profit_taker_analyzer/utils/screenshot.dart';

import 'package:profit_taker_analyzer/screens/home/home_widgets.dart';
import 'package:profit_taker_analyzer/screens/home/home_data.dart';

import 'package:profit_taker_analyzer/widgets/dialogs.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:profit_taker_analyzer/widgets/loading_overlay.dart';
import 'package:profit_taker_analyzer/widgets/last_runs.dart';

/// Track if the drawer is open to disable scroll shortcut
bool isDrawerOpen = false;

class HomeScreen extends StatefulWidget {
  final String fileName;
  final int fileIndex;

  const HomeScreen(
      {super.key, required this.fileName, required this.fileIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  /// A [GlobalKey] for the [Scaffold] widget, enabling programmatic control over the drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// A [ValueNotifier] that holds the current connection status.
  final ValueNotifier<bool> _connectionStatus = ValueNotifier<bool>(true);

  /// Controller for file name edit field.
  final _textFieldController = TextEditingController();

  /// A timer for periodic data fetching.
  Timer? _dataFetch;

  /// A controller for taking screenshots.
  ScreenshotController screenshotController = ScreenshotController();

  /// Indicates whether the state should be kept alive (mounted) even when it's not visible.
  @override
  bool get wantKeepAlive => true;

  /// A [ValueNotifier] that tracks whether the shortcut is enabled.
  final ValueNotifier<bool> _shortcutEnabled = ValueNotifier<bool>(true);

  final _keyboardListenerFocus = FocusNode();

  /// Loads the data from the last run based on the provided file name.
  ///
  /// This method displays a loading overlay, loads the data file with the given file name,
  /// and updates the UI after the data is loaded. Once the data is loaded, the loading overlay
  /// is hidden.
  ///
  /// Parameters:
  ///   - fileName: The name of the file containing the data to be loaded.
  void loadLastRunData(String fileName, int index) {
    LoadingOverlay.of(context).show();
    loadDataFile('$fileName.json').then((_) {
      setState(() {});
      LoadingOverlay.of(context).hide();
      currentIndex = index;
    });
  }

  List<File> allRuns = []; // List of all runs as file objects
  List<String> runFilenames = []; // List to store all run filenames
  int currentIndex = 0; // Current index in the list of run filenames

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print("Opened home screen");
    }

    /// Get best times
    findLowestTimes();

    /// Listen for changes in screen dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateShortcutEnabled();
    });

    // Add the observer to WidgetsBinding.instance
    WidgetsBinding.instance.addObserver(this);

    /// Populate lists with run history
    allRuns = getStoredRuns();
    getRunFileNames(allRuns, allRuns.length, runFilenames);

    // Reset timestamp
    // lastUpdateTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

    // Load specific run chosen from Storage Screen
    if (widget.fileName != '') {
      // Prevent updating to data from API
      lastUpdateTimestamp = DateTime.now();
      loadDataFile("${widget.fileName}.json").then((_) {
        currentIndex = widget.fileIndex;
        setState(() {});
        LoadingOverlay.of(context).hide();
      });
    }

    /// Fetch the data for last run
    _dataFetch =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      int result = await checkForNewData();
      if (result == noNewDataAvailable) {
        _connectionStatus.value = true;
        return;
      }
      if (result == newDataAvailable && mounted) {
        _connectionStatus.value = true;
        LoadingOverlay.of(context).show();
        await loadDataAPI().then((_) {
          /// Get best times
          findLowestTimes();

          /// Populate lists with run history
          allRuns = getStoredRuns();
          getRunFileNames(allRuns, allRuns.length, runFilenames);
          currentIndex = 0;

          /// Refresh UI
          setState(() {});
          LoadingOverlay.of(context).hide();
        });
        return;
      }
      if (result == connectionError) {
        _connectionStatus.value = false;
        return;
      }
    });

    _keyboardListenerFocus.requestFocus();

    // Schedule a callback for the end of this frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Removed version popup for now
      // if (!isMostRecentVersion) {
      //   // Show the dialog if the app is not the most recent version
      //   showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text(FlutterI18n.translate(context, "update.title")),
      //         content: Text(FlutterI18n.translate(context, "update.text")),
      //         actions: <Widget>[
      //           TextButton(
      //             child: Text(FlutterI18n.translate(context, "buttons.cancel")),
      //             onPressed: () {
      //               Navigator.of(context).pop(); // Close the dialog
      //             },
      //           ),
      //           TextButton(
      //             child:
      //                 Text(FlutterI18n.translate(context, "buttons.download")),
      //             onPressed: () async {
      //               await Shell()
      //                   .run('runas /user:Administrator "update/update.exe"');
      //               exit(0);
      //             },
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // }
    });
  }

  /// Updates the state of the shortcut based on screen dimensions.
  void _updateShortcutEnabled() {
    // Get the current screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Determine if the shortcut should be enabled
    bool shouldEnableShortcut = false;
    compactModeEnabled
        ? shouldEnableShortcut = screenWidth >= 940 && screenHeight > 990 ||
            screenWidth >= 1510 && screenHeight > 605
        : shouldEnableShortcut = screenWidth >= startingWidth - 165 &&
            screenHeight >= startingHeight - 60;
    // Update the ValueNotifier
    _shortcutEnabled.value = shouldEnableShortcut;
  }

  @override
  void didChangeMetrics() {
    // Screen dimensions changed, update the shortcut state
    Future.delayed(const Duration(milliseconds: 50), () {
      _updateShortcutEnabled();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _keyboardListenerFocus.requestFocus();
  }

  /// Disposes of resources used by the `_HomeScreenState` class.
  ///
  /// This method is automatically called when the associated widget is removed from the widget tree.
  /// It cancels the periodic data fetching timer [_dataFetch], preventing memory leaks
  /// and ensuring proper cleanup.
  @override
  void dispose() {
    _dataFetch?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Access the current locale
    final currentLocale = FlutterI18n.currentLocale(context);

    /// Callback function for updating data.
    ///
    /// This function displays a loading overlay, updates the state, and then hides the loading overlay.
    ///
    /// Parameters:
    ///   - newName: The new name to be updated.
    ///   - fileName: The file name associated with the update.
    void updateCallback(String newName, String fileName) {
      LoadingOverlay.of(context).show();
      setState(() {});
      LoadingOverlay.of(context).hide();
    }

    /// Handles the functionality when the back button is pressed.
    void onBackButtonPressed() {
      if (currentIndex < runFilenames.length - 1) {
        LoadingOverlay.of(context).show();
        currentIndex++;
        loadDataFile(runFilenames[currentIndex]).then((_) {
          setState(() {});
          LoadingOverlay.of(context).hide();
        });
      }
    }

    /// Handles the functionality when the forward button is pressed.
    void onForwardButtonPressed() {
      if (currentIndex > 0) {
        LoadingOverlay.of(context).show();
        currentIndex--;
        loadDataFile(runFilenames[currentIndex]).then((_) {
          setState(() {});
          LoadingOverlay.of(context).hide();
        });
      }
    }

    // Localized error messages
    String errorTitle = FlutterI18n.translate(context, "errors.error");
    String parserErrorMessage =
        FlutterI18n.translate(context, "errors.parser_connection_error");
    String buggedRunWarningMessage =
        FlutterI18n.translate(context, "errors.bugged_run_warning");
    String abortedRunWarningMessage =
        FlutterI18n.translate(context, "errors.aborted_run_warning");
    String editTitle = FlutterI18n.translate(context, "alerts.name_title");
    String okButton = FlutterI18n.translate(context, "buttons.ok");
    String cancelButton = FlutterI18n.translate(context, "buttons.cancel");

    /// Calculate available spaces for Last Run elements
    ///
    /// We need to know how many runs we can fit in the last runs drawer widget, so
    /// we calculate the max here and then send it to the Drawer
    int maxLastRunItems = (MediaQuery.of(context).size.height / 50).ceil();

    // Calculate available screen width
    double screenWidth = MediaQuery.of(context).size.width -
        (totalLeftPaddingHome) -
        13; // 13 pixels to make left side padding the same as the right side

    /// Function to handle keyboard arrow key presses
    bool handleArrowKeys(RawKeyEvent event) {
      if (event is RawKeyDownEvent && !isDrawerOpen) {
        if (event.logicalKey == upActionKey) {
          onForwardButtonPressed();
          // Indicate the event is consumed
          return true;
        } else if (event.logicalKey == downActionKey && !isDrawerOpen) {
          onBackButtonPressed();
          // Indicate the event is consumed
          return true;
        }
      }
      return true;
    }

    // Build the overall widget tree
    return RawKeyboardListener(
      focusNode: _keyboardListenerFocus,
      onKey: handleArrowKeys,
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
              backgroundColor: Theme.of(context).colorScheme.background,
              key: _scaffoldKey,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 60, top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          titleText(
                              'Profit Taker Analytics', 32, FontWeight.bold),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: _connectionStatus,
                                  builder: (context, isConnected, _) {
                                    if (!isConnected) {
                                      return IconButton(
                                        icon: Icon(
                                          Icons.warning,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        onPressed: () {
                                          showParserConnectionErrorDialog(
                                              context,
                                              errorTitle,
                                              parserErrorMessage);
                                        },
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: onBackButtonPressed,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: onForwardButtonPressed,
                                ),
                                IconButton(
                                  icon: Icon(compactModeEnabled
                                      ? Icons.table_rows_rounded
                                      : Icons.view_agenda),
                                  onPressed: () {
                                    setState(() {
                                      compactModeEnabled = !compactModeEnabled;
                                      _updateShortcutEnabled();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(MyApp.themeNotifier.value ==
                                          ThemeMode.light
                                      ? Icons.nightlight
                                      : Icons.wb_sunny),
                                  onPressed: () => switchTheme(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: drawerButton(_scaffoldKey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      titleText(
                          username == ''
                              ? FlutterI18n.translate(context, "home.hello")
                              : FlutterI18n.translate(
                                  context, "home.hello_name",
                                  translationParams: {"name": username}),
                          24,
                          FontWeight.normal),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Flexible(
                            child: currentLocale!.languageCode == 'tr'
                                ? mostRecentRun == true
                                    ? titleText(
                                        FlutterI18n.translate(context, "home.last_run"), 20, FontWeight.w500,
                                        overflow: TextOverflow.ellipsis)
                                    // OTHER LANGUAGES
                                    : titleText(FlutterI18n.translate(context, "home.run"),
                                        20, FontWeight.w500,
                                        overflow: TextOverflow.ellipsis)
                                : mostRecentRun == true
                                    ? titleText(
                                        soloRun == true
                                            ? FlutterI18n.translate(
                                                context, "home.last_run")
                                            : FlutterI18n.translate(context, "home.last_run_with") +
                                                (playersListStart.isNotEmpty
                                                    ? playersListStart +
                                                        FlutterI18n.translate(
                                                            context, "home.and")
                                                    : "") +
                                                playersListEnd,
                                        20,
                                        FontWeight.w500,
                                        overflow: TextOverflow.ellipsis)
                                    : titleText(
                                        soloRun == true
                                            ? FlutterI18n.translate(context, "home.run")
                                            : FlutterI18n.translate(context, "home.last_run_with") + (playersListStart.isNotEmpty ? playersListStart + FlutterI18n.translate(context, "home.and") : "") + playersListEnd,
                                        20,
                                        FontWeight.w500,
                                        overflow: TextOverflow.ellipsis),
                          ),
                          currentLocale.languageCode == 'tr'
                              ? const SizedBox(
                                  width: 0,
                                )
                              : titleText(
                                  " ${FlutterI18n.translate(context, "home.named")} ",
                                  20,
                                  FontWeight.w500),
                          titleText(
                              customRunName.isEmpty
                                  ? "\"$runFileName\""
                                  : "\"$customRunName\"",
                              20,
                              FontWeight.w500),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () async {
                              var fileNames = await getExistingFileNames();
                              displayTextInputDialog(
                                  context,
                                  _textFieldController,
                                  runFileName,
                                  customRunName.isEmpty
                                      ? runFileName
                                      : customRunName,
                                  editTitle,
                                  cancelButton,
                                  okButton,
                                  fileNames,
                                  updateCallback);
                            },
                          ),
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
                          (isBuggedRun || isAbortedRun) == true
                              ? IconButton(
                                  icon: Icon(
                                    Icons.warning,
                                    color: isBuggedRun
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.yellow,
                                  ),
                                  onPressed: () {
                                    if (isBuggedRun) {
                                      showBuggedRunWarningDialog(context,
                                          errorTitle, buggedRunWarningMessage);
                                    }
                                    if (isAbortedRun) {
                                      showBuggedRunWarningDialog(context,
                                          errorTitle, abortedRunWarningMessage);
                                    }
                                  },
                                )
                              : Container(),
                        ],
                      ),
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
                                                index, context, screenWidth)),
                                        ...List.generate(
                                            4,
                                            (index) => buildCompactPhaseCard(
                                                index, context, screenWidth)),
                                      ]
                                    : [
                                        ...List.generate(
                                            6,
                                            (index) => buildOverviewCard(
                                                index, context, screenWidth)),
                                        ...List.generate(
                                            4,
                                            (index) => buildPhaseCard(
                                                index, context, screenWidth)),
                                      ],
                              ),
                            ],
                          )),
                      const SizedBox(height: 12), // Space between elements
                    ],
                  ),
                ),
              ),
              endDrawer: HomePageDrawer(
                  maxItems: maxLastRunItems, onItemSelected: loadLastRunData),
            ),
          );
        },
      ),
    );
  }
}
