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

/// Builds and returns a card widget for displaying overview information.
///
/// This method creates a card with specific styling based on the provided [index],
/// [BuildContext], and [screenWidth]. The card displays information such as title,
/// icon, and time value with color-coding based on predefined thresholds.
///
/// Parameters:
///   - `index`: The index of the card in the overviewCards list.
///   - `context`: The build context providing access to the theme and localization.
///   - `screenWidth`: The available width of the screen.
///
/// Returns:
///   A widget representing an overview card with dynamic styling.
Widget buildOverviewCard(int index, BuildContext context, double screenWidth) {
  // Extra 8 pixels for padding
  // NOTE: I'm not sure why this needs padding and the other doesn't...
  double responsiveCardWidth = screenWidth / 6 - 8;

  /// Determines the color for the total time value
  Color color;
  if (index == 0) {
    double timeValue = double.parse(overviewCards[index].time);

    if (timeValue < 52.000) {
      color = const Color(0xFFb33dc6);
    } else if (timeValue < 60.000) {
      color = const Color(0xFF27aeef);
    } else if (timeValue < 80.000) {
      color = const Color(0xFFbdcf32);
    } else if (timeValue < 120.000) {
      color = const Color(0xFF35967D);
    } else if (timeValue < 150.000) {
      color = const Color(0xFFef9b20);
    } else if (timeValue > 150.000) {
      color = const Color(0xFFea5545);
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

/// Builds and returns a card widget for displaying phase information.
///
/// This method creates a card with specific styling based on the provided [index],
/// [BuildContext], and [screenWidth]. The card displays information such as phase title,
/// duration, and details about shields, legs, and other phase-specific data.
///
/// Parameters:
///   - `index`: The index of the card in the phaseCards list.
///   - `context`: The build context providing access to the theme and localization.
///   - `screenWidth`: The available width of the screen.
///
/// Returns:
///   A widget representing a phase card with dynamic styling and details.
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
                          spacing: 20.0,
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

/// Builds and returns an [IconButton] for opening the end drawer.
///
/// This method creates an [IconButton] with the specified icon and size.
/// When pressed, it triggers the opening of the end drawer associated with
/// the provided [scaffoldKey].
///
/// Parameters:
///   - `scaffoldKey`: A [GlobalKey] for the [Scaffold] widget to control the drawer.
///
/// Returns:
///   An [IconButton] with an icon for opening the end drawer.
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
