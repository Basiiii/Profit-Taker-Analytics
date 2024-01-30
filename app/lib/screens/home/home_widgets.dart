import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:profit_taker_analyzer/constants/constants.dart';

import 'package:profit_taker_analyzer/screens/home/home_data.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';

/// Builds a Row widget with the specified parameters.
///
/// This function creates a Row widget with a label and time. The label is
/// displayed with a font size of 16 and font weight of 400. The time is
/// displayed with a font size of 16, font family 'DMMono', and aligns to
/// the right. The color of the time text is determined by the theme's surface variant.
///
/// ```dart
/// buildRow(context, "Label", "Time");
/// ```
///
/// The above code will produce a Row widget with a label and time. The label
/// will be displayed with a font size of 16 and font weight of 400. The time
/// will be displayed with a font size of 16, font family 'DMMono', and aligns
/// to the right. The color of the time text will be determined by the theme's
/// surface variant.
///
/// Parameters:
/// * [context]: The build context.
/// * [label]: The label to be displayed.
/// * [time]: The time to be displayed.
///
/// Returns:
/// A [Row] widget with the specified parameters.
Widget buildRow(BuildContext context, String label, String time) {
  return Row(
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      Expanded(
        child: Text(
          time,
          style: TextStyle(
              fontSize: 16,
              fontFamily: 'DMMono',
              color: Theme.of(context).colorScheme.surfaceVariant),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}

/// Builds an overview card widget with the specified parameters.
///
/// This function creates an overview card widget with a given index, context,
/// and screen width.
/// The card has a width of 200 and height of 135, with a decoration that includes
/// a color scheme and a border radius. The card contains a column of widgets,
/// including a container with an icon, a title, and rich text displaying time.
///
/// ```dart
/// buildOverviewCard(index, context, screenWidth);
/// ```
///
/// The above code will produce an overview card widget with a given index, context,
/// and screen width. The card will contain a column of widgets, including a container
/// with an icon, a title, and rich text displaying time.
///
/// Parameters:
/// * [index]: The index of the overview card.
/// * [context]: The build context.
/// * [screenWidth]: The width of the screen to calculate the responsive card width.
///
/// Returns:
/// An [OverviewCard] widget with the specified parameters.
Widget buildOverviewCard(int index, BuildContext context, double screenWidth) {
  // Extra 8 pixels for padding
  // NOTE: I'm not sure why this needs padding and the other doesn't...
  double responsiveCardWidth = screenWidth / 6 - 8;

  Color color;
  if (index == 0) {
    double timeValue = double.parse(overviewCards[index].time);

    if (timeValue < 52.000) {
      color = const Color(0xFFA488FF);
    } else if (timeValue < 60.000) {
      color = const Color(0xFF7361D8);
    } else if (timeValue < 70.000) {
      color = const Color(0xFF33BDCC);
    } else if (timeValue < 90.000) {
      color = const Color(0xFF35967D);
    } else if (timeValue > 90.000) {
      color = const Color(0xFFB85E2C);
    } else {
      color = Theme.of(context).colorScheme.onSurface;
    }
  } else {
    color = Theme.of(context).colorScheme.onSurface;
  }

  return Container(
    width: screenWidth < minimumResponsiveWidth
        ? overviewCardWidth
        : responsiveCardWidth,
    height: 135,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: overviewCards[index].color,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(overviewCards[index].icon,
                          size: 25,
                          color: Theme.of(context).colorScheme.surface)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        FlutterI18n.translate(context,
                            "overview_cards.${overviewCards[index].title}"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 25),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                generateRichText(context, [
                  generateTextSpan(
                      overviewCards[index].time, 32, FontWeight.w600,
                      color: color),
                  generateTextSpan('s ', 20, FontWeight.w400, color: color),
                ]),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// Builds a phase card widget with the specified parameters.
///
/// This function creates a phase card widget with a given index, context,
/// and screen width.
/// The card has a width of 625 and height of 160, with a decoration that includes
/// a color scheme and a border radius. The card contains a column of widgets,
/// including a row with a title and time, and rows of labels with corresponding times.
/// Depending on the index, different labels are shown.
///
/// ```dart
/// buildPhaseCard(index, context, screenWidth);
/// ```
///
/// The above code will produce a phase card widget with a given index, context,
/// and screen width. The card will contain a column of widgets, including a row
/// with a title and time, and rows of labels with corresponding times. Depending
/// on the index, different labels are shown.
///
/// Parameters:
/// * [index]: The index of the phase card.
/// * [context]: The build context.
/// * [screenWidth]: The width of the screen to calculate the responsive card width.
///
/// Returns:
/// A [PhaseCard] widget with the specified parameters.
Widget buildPhaseCard(int index, BuildContext context, double screenWidth) {
  double responsiveCardWidth = screenWidth / 2;

  List<String> labels = [
    FlutterI18n.translate(context, "phase_cards.shields"),
    FlutterI18n.translate(context, "phase_cards.legs"),
    FlutterI18n.translate(context, "phase_cards.body"),
    FlutterI18n.translate(context, "phase_cards.pylons"),
  ];

  List<Widget> rows;

  List<String> overviewList = phaseCards[index].overviewList;

  if (index == 1) {
    rows = labels
        .sublist(1, 3)
        .asMap()
        .entries
        .map((entry) => buildRow(context, entry.value, overviewList[entry.key]))
        .toList();
  } else if (index == 3) {
    rows = labels
        .sublist(0, 3)
        .asMap()
        .entries
        .map((entry) => buildRow(context, entry.value, overviewList[entry.key]))
        .toList();
  } else {
    rows = labels
        .asMap()
        .entries
        .map((entry) => buildRow(context, entry.value, overviewList[entry.key]))
        .toList();
  }

  return Container(
    width: screenWidth < minimumResponsiveWidth
        ? phaseCardWidth
        : responsiveCardWidth,
    height: 160,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  FlutterI18n.translate(
                      context, "phase_cards.${phaseCards[index].title}"),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      generateRichText(context, [
                        generateTextSpan(
                            phaseCards[index].time, 20, FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface),
                        generateTextSpan('s ', 20, FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
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
                        index != 1
                            ? Wrap(
                                spacing: 20.0,
                                runSpacing: 8.0,
                                direction: Axis.horizontal,
                                children:
                                    phaseCards[index].shieldsList.map((pair) {
                                  return SizedBox(
                                    width: 65,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(pair['icon'], size: 14),
                                        Text(
                                          pair['text'],
                                          style: TextStyle(
                                              fontFamily: 'DMMono',
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            : const SizedBox.shrink(),
                        index != 1
                            ? const SizedBox(height: 6)
                            : const SizedBox.shrink(),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          direction: Axis.horizontal,
                          children: phaseCards[index].legsList.map((pair) {
                            return SizedBox(
                              width: 65,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(pair['icon'], size: 8),
                                  Text(
                                    pair['text'],
                                    style: TextStyle(
                                        fontFamily: 'DMMono',
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ),
  );
}

/// Creates an IconButton widget for drawer.
///
/// This function generates an IconButton widget with a specific icon. When
/// the button is pressed, it opens the end drawer of the scaffold.
///
/// ```dart
/// drawerButton(GlobalKey<ScaffoldState> scaffoldKey);
/// ```
///
/// The above code will produce an IconButton with a specific icon. When
/// the button is pressed, it will open the end drawer of the scaffold.
///
/// Parameters:
/// * [scaffoldKey]: The key of the scaffold.
///
/// Returns:
/// An [IconButton] widget that opens the end drawer when pressed.
IconButton drawerButton(GlobalKey<ScaffoldState> scaffoldKey) {
  return IconButton(
    icon: const Icon(
      Icons.view_headline,
      size: 24,
    ),
    onPressed: () {
      scaffoldKey.currentState!.openEndDrawer();
    },
  );
}

/// The home page drawer widget.
///
/// This widget is our home page drawer, it's where we will store past runs.
/// It contains a ListView with a list of items. Each item in the list is represented by a ListTile widget.
class HomePageDrawer extends StatelessWidget {
  const HomePageDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.only(left: 5, top: 10),
          children: <Widget>[
            const ListTile(
              title: Text(
                'Latest runs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                hoverColor: Theme.of(context).colorScheme.surfaceVariant,
                title: const Text(
                  'Coming soon!',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
