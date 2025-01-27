import 'package:flutter/material.dart';

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
