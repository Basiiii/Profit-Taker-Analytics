import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This class defines our custom navigation bar widget, used on left side.
class NavigationBar extends StatefulWidget {
  /// A callback function that gets triggered when a tab is selected.
  final Function(int) onTabSelected;

  /// Creates a new instance of NavigationBar.
  const NavigationBar({super.key, required this.onTabSelected});

  /// Returns the state object for this widget.
  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

/// Represents the mutable state for a NavigationBar.
class _NavigationBarState extends State<NavigationBar> {
  /// Keeps track of the currently selected tab.
  int _currentIndex = 0;

  /// Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildNavItem('assets/HOME_ICON.svg', 0),
          const SizedBox(height: 20),
          _buildNavItem('assets/BOX_ICON.svg', 1),
          const SizedBox(height: 20),
          _buildNavItem('assets/SETTINGS_ICON.svg', 2),
        ],
      ),
    );
  }

  /// Builds a single navigation item.
  Widget _buildNavItem(String svgAsset, int index) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Positioned(
          right: 0,
          child: Container(
            width: 3,
            height: 24,

            /// Only highlights current index with primary color
            color: _currentIndex == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
          ),
        ),
        Center(
          child: IconButton(
            icon: SvgPicture.asset(
              svgAsset,
              colorFilter: ColorFilter.mode(
                _currentIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              setState(() {
                _currentIndex = index;
              });
              widget.onTabSelected(index);
            },
          ),
        ),
      ],
    );
  }
}
