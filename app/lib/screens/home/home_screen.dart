import 'dart:async';

import 'package:flutter/foundation.dart';
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

/// The HomeScreen widget represents the home screen of the application.
///
/// This widget uses a Scaffold to provide a basic structure for the app,
/// including an AppBar and a Body. The body of the scaffold is a single
/// child scroll view, containing various widgets such as titles, buttons,
/// and cards.
///
/// Example usage:
/// ```dart
/// HomeScreen()
/// ```
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The _HomeScreenState class represents the mutable state for the HomeScreen widget.
///
/// This class contains a GlobalKey for the Scaffold, which allows for
/// opening and closing of drawers programmatically.
class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<bool> _connectionStatus = ValueNotifier<bool>(true);

  Timer? _healthCheck;
  Timer? _dataFetch;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    _healthCheck =
        Timer.periodic(const Duration(milliseconds: 5555), (timer) async {
      bool isConnected = await checkConnection();
      _connectionStatus.value = isConnected;
      if (kDebugMode) {
        _connectionStatus.value
            ? print("There is connection")
            : print("No connection");
      }
    });

    _dataFetch = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (await checkForNewData() == true && mounted) {
        LoadingOverlay.of(context).show();
        await loadData().then((_) {
          setState(() {});
          LoadingOverlay.of(context).hide();
        });
      }
    });
  }

  @override
  void dispose() {
    _healthCheck?.cancel();
    _dataFetch?.cancel();
    super.dispose();
  }

  /// Overrides the build method to construct the widget tree.
  ///
  /// This method returns a Scaffold widget, which provides a framework
  /// for major parts of the material design visual layout structure, such as
  /// an AppBar and a Body.
  @override
  Widget build(BuildContext context) {
    String errorTitle = FlutterI18n.translate(context, "errors.error");
    String parserErrorMessage =
        FlutterI18n.translate(context, "errors.parser_connection_error");

    double screenWidth =
        MediaQuery.of(context).size.width - (totalLeftPaddingHome);

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
      endDrawer: const HomePageDrawer(),
    );
  }
}
