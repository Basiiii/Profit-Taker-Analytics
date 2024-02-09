import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:profit_taker_analyzer/screens/home/home_screen.dart';

/// A custom navigation bar widget used on the left side of the application.
///
/// The `NavigationBar` widget provides a vertical navigation bar with
/// customizable icons for different tabs. It includes a callback function
/// to notify when a tab is selected.
class NavigationBar extends StatelessWidget {
  /// The current selected index of the navigation bar.
  final int currentIndex;

  /// A callback function to be called when a tab is selected.
  final Function(int, {String? fileName, int? runIndex}) onTabSelected;

  final String? fileName;

  /// Constructs a [NavigationBar] widget.
  ///
  /// Parameters:
  ///   - `currentIndex`: The current selected index of the navigation bar.
  ///   - `onTabSelected`: A callback function to be called when a tab is selected.
  const NavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      descendantsAreFocusable: false,
      child: Container(
        width: 80,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildNavItem(context, 'assets/icons/HOME_GREY.svg',
                'assets/icons/HOME_SELECTED.svg', 0),
            const SizedBox(height: 20),
            _buildNavItem(context, 'assets/icons/STORAGE_GREY.svg',
                'assets/icons/STORAGE_SELECTED.svg', 1),
            const SizedBox(height: 20),
            _buildNavItem(context, 'assets/icons/SETTINGS_GREY.svg',
                'assets/icons/SETTINGS_SELECTED.svg', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String greyIconAsset,
      String selectedIconAsset, int index) {
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
              // Determine the fileName and runIndex values here
              String? fileNameValue = ''; // Replace with actual value
              int? runIndexValue = 0; // Replace with actual value

              onTabSelected(index,
                  fileName: fileNameValue, runIndex: runIndexValue);
            },
          ),
        ),
      ],
    );
  }
}
