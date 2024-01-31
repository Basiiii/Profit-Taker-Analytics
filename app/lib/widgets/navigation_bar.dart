import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A custom navigation bar widget used on the left side of the application.
///
/// The `NavigationBar` widget provides a vertical navigation bar with
/// customizable icons for different tabs. It includes a callback function
/// to notify when a tab is selected.
class NavigationBar extends StatelessWidget {
  /// The current selected index of the navigation bar.
  final int currentIndex;

  /// A callback function to be called when a tab is selected.
  final Function(int) onTabSelected;

  /// Constructs a [NavigationBar] widget.
  ///
  /// Parameters:
  ///   - `currentIndex`: The current selected index of the navigation bar.
  ///   - `onTabSelected`: A callback function to be called when a tab is selected.
  const NavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildNavItem('assets/icons/HOME_GREY.svg',
              'assets/icons/HOME_SELECTED.svg', 0),
          const SizedBox(height: 20),
          _buildNavItem('assets/icons/STORAGE_GREY.svg',
              'assets/icons/STORAGE_SELECTED.svg', 1),
          const SizedBox(height: 20),
          _buildNavItem('assets/icons/SETTINGS_GREY.svg',
              'assets/icons/SETTINGS_SELECTED.svg', 2),
        ],
      ),
    );
  }

  /// Builds a navigation item with an icon.
  ///
  /// Parameters:
  ///   - `greyIconAsset`: The asset path for the grey version of the icon.
  ///   - `selectedIconAsset`: The asset path for the selected version of the icon.
  ///   - `index`: The index associated with the navigation item.
  Widget _buildNavItem(
      String greyIconAsset, String selectedIconAsset, int index) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Center(
          child: IconButton(
            icon: SvgPicture.asset(
              currentIndex == index ? selectedIconAsset : greyIconAsset,
              width: 22,
              height: 22,
            ),
            onPressed: () {
              onTabSelected(index);
            },
          ),
        ),
      ],
    );
  }
}
