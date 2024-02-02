import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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

/// The HomeScreen widget represents the main screen of the application.
///
/// This widget uses a Scaffold to provide a basic structure for the app,
/// including an AppBar and a Body. The body of the scaffold is a single
/// child scroll view, containing various widgets such as titles, buttons,
/// and cards.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The `_HomeScreenState` class represents the mutable state for the `HomeScreen` widget.
///
/// This class contains a [GlobalKey] for the [Scaffold], which allows for
/// opening and closing of drawers programmatically.
class _HomeScreenState extends State<HomeScreen> {
  /// A [GlobalKey] for the [Scaffold] widget, enabling programmatic control over the drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// A [ValueNotifier] that holds the current connection status.
  ValueNotifier<bool> _connectionStatus = ValueNotifier<bool>(true);

  /// A timer for periodic data fetching.
  Timer? _dataFetch;

  /// A controller for taking screenshots.
  ScreenshotController screenshotController = ScreenshotController();

  void loadLastRunData(String fileName) {
    LoadingOverlay.of(context).show();
    loadDataFile(fileName).then((_) {
      setState(() {});
      LoadingOverlay.of(context).hide();
    });
  }

  /// Initializes the state of the `_HomeScreenState` class.
  ///
  /// This method sets up the periodic data fetching timer and handles various scenarios
  /// such as checking for new data, handling connection errors, and loading data.
  @override
  void initState() {
    super.initState();

    /// Fetch the data for last run
    _dataFetch =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      int result = await checkForNewData();
      if (result == noNewDataAvailable) {
        _connectionStatus = ValueNotifier<bool>(true);
        return;
      }
      if (result == newDataAvailable && mounted) {
        _connectionStatus = ValueNotifier<bool>(true);
        LoadingOverlay.of(context).show();
        await loadDataAPI().then((_) {
          setState(() {});
          LoadingOverlay.of(context).hide();
        });
        return;
      }
      if (result == connectionError) {
        _connectionStatus == ValueNotifier<bool>(false);
        return;
      }
    });
  }

  /// Disposes of resources used by the `_HomeScreenState` class.
  ///
  /// This method is automatically called when the associated widget is removed from the widget tree.
  /// It cancels the periodic data fetching timer [_dataFetch], preventing memory leaks
  /// and ensuring proper cleanup.
  @override
  void dispose() {
    _dataFetch?.cancel();
    super.dispose();
  }

  /// Builds and returns the widget tree for the `_HomeScreenState`.
  ///
  /// This method is responsible for constructing the UI components and layout
  /// of the `HomeScreen` widget. It utilizes localized error messages and calculates
  /// the available screen width based on the device's screen size and padding.
  ///
  /// The resulting widget tree is wrapped in a [Scaffold] for the overall structure,
  /// and a [SingleChildScrollView] for scrollable content.
  ///
  /// Parameters:
  ///   - `context`: The build context providing access to the localization and theme.
  ///
  /// Returns:
  ///   A widget tree representing the visual elements of the `HomeScreen`.
  @override
  Widget build(BuildContext context) {
    // Localized error messages
    String errorTitle = FlutterI18n.translate(context, "errors.error");
    String parserErrorMessage =
        FlutterI18n.translate(context, "errors.parser_connection_error");

    /// Calculate available spaces for Last Run elements
    ///
    /// We need to know how many runs we can fit in the last runs drawer widget, so
    /// we calculate the max here and then send it to the Drawer
    int maxLastRunItems = (MediaQuery.of(context).size.height / 50).ceil();

    // Calculate available screen width
    double screenWidth =
        MediaQuery.of(context).size.width - (totalLeftPaddingHome);

    // Build the overall widget tree
    return Scaffold(
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
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      onPressed: () {
                                        showParserConnectionErrorDialog(context,
                                            errorTitle, parserErrorMessage);
                                      },
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                    MyApp.themeNotifier.value == ThemeMode.light
                                        ? Icons.nightlight
                                        : Icons.wb_sunny),
                                onPressed: () => switchTheme(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: drawerButton(_scaffoldKey),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    titleText(
                        username == ''
                            ? FlutterI18n.translate(context, "home.hello")
                            : FlutterI18n.translate(context, "home.hello_name",
                                translationParams: {"name": username}),
                        24,
                        FontWeight.normal),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        titleText(
                            FlutterI18n.translate(context, "home.last_run"),
                            20,
                            FontWeight.w500),
                        IconButton(
                          icon: const Icon(Icons.share, size: 18),
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
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Screenshot(
                        controller: screenshotController,
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Wrap(
                                    spacing: 12.0,
                                    runSpacing: 12.0,
                                    children: [
                                      ...List.generate(
                                          6,
                                          (index) => buildOverviewCard(
                                              index, context, screenWidth)),
                                      ...List.generate(
                                          4,
                                          (index) => buildPhaseCard(
                                              index, context, screenWidth)),
                                    ])),
                          ],
                        )),
                    const SizedBox(height: 12), // Space between elements
                  ]))),
      endDrawer: HomePageDrawer(
          maxItems: maxLastRunItems, onItemSelected: loadLastRunData),
    );
  }
}
