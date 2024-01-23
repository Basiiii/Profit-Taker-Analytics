import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/home_widgets.dart';

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

  /// Overrides the build method to construct the widget tree.
  ///
  /// This method returns a Scaffold widget, which provides a framework
  /// for major parts of the material design visual layout structure, such as
  /// an AppBar and a Body.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(left: 60, top: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          titleText(
                              'Profit Taker Analytics', 32, FontWeight.bold),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: iconButton(_scaffoldKey),
                          )
                        ]),
                    titleText('Hello User!', 24, FontWeight.normal),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        titleText('Your last run', 20, FontWeight.w500),
                        IconButton(
                          icon: const Icon(Icons.share, size: 18),
                          onPressed: () {
                            // TODO: Implement share feature (image to clipboard)
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                children: [
                                  ...List.generate(
                                      6,
                                      (index) =>
                                          buildOverviewCard(index, context)),
                                  ...List.generate(
                                      4,
                                      (index) =>
                                          buildPhaseCard(index, context)),
                                ])),
                      ],
                    ),
                    const SizedBox(height: 12), // Space between elements
                  ]))),
      endDrawer: Drawer(
        //TODO: DATA FROM DRAWER MUST BE FETCHED DYNAMICALLY
        child: Container(
          color: const Color(0xFF070417),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Latest runs',
                  style: TextStyle(
                    fontSize: (MediaQuery.of(context).size.width * 0.02)
                        .clamp(10, 30),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  '15/11/2023 @ 15:04',
                  style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width * 0.01)
                          .clamp(10, 15)),
                ),
                onTap: () {
                  // TODO: BUTTON MUST LOAD DATA FROM SPECIFIC RUN CHOSEN
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
