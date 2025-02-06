import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/widgets/ui/theme_switcher.dart';

// TODO: document
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
