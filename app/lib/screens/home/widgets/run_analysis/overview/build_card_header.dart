import 'package:flutter/material.dart';

/// Builds the header for a card widget, displaying an icon and a text.
///
/// [context] The build context used for widget rendering.
/// [color] The background color of the icon container.
/// [icon] The icon to be displayed in the container.
/// [text] The text to be displayed next to the icon, either a title or time.
/// [isCompact] A boolean flag to determine if the layout should be more compact.
/// [textColor] An optional color for the text, used only when [isCompact] is true.
Widget buildCardHeader(
    BuildContext context, Color color, IconData icon, String text,
    {bool isCompact = false, Color? textColor}) {
  return Padding(
    padding: isCompact
        ? EdgeInsets.only(top: 13, left: 20)
        : EdgeInsets.only(top: 15, left: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 25,
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text, // Either title or time (based on isCompact)
          style: TextStyle(
            fontSize: isCompact ? 32 : 16, // Larger size for time
            fontWeight: isCompact ? FontWeight.w600 : FontWeight.w400,
            color: isCompact ? textColor : Colors.white,
            height: 1.05,
          ),
        ),
      ],
    ),
  );
}
