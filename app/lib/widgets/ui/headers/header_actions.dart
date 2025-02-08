import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/widgets/ui/theme_switcher.dart';

/// A widget that displays a row of header action buttons with a theme switcher.
///
/// This widget takes a list of action widgets and arranges them in a row,
/// aligned to the end of the available space. It also includes a [ThemeSwitcher]
/// and a spacer for consistent layout.
///
/// ### Example Usage:
/// ```dart
/// HeaderActions(
///   actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
/// )
/// ```
///
/// The above example creates a header with a settings button and a theme switcher.
///
/// #### Parameters:
/// - `actions`: A list of widgets representing header actions.
class HeaderActions extends StatelessWidget {
  final List<Widget> actions;

  const HeaderActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...actions,
          const ThemeSwitcher(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
