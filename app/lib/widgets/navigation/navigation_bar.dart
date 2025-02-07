import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';

/// A custom navigation bar widget used on the left side of the application.
///
/// The `NavigationBar` widget provides a vertical navigation bar with
/// customizable icons for different tabs. It includes a callback function
/// to notify when a tab is selected.
///
/// The icons change based on the selected tab, with each tab represented by
/// a grey icon when unselected and a highlighted icon when selected.
class NavigationBar extends StatelessWidget {
  /// The index of the currently selected tab.
  final int currentIndex;

  /// A callback function that is triggered when a tab is selected.
  /// It receives the index of the selected tab as a parameter.
  final Function(int) onTabSelected;

  const NavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      descendantsAreFocusable: false,
      child: Container(
        width: 80,
        color: Theme.of(context).colorScheme.surfaceBright,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildNavItem(context, AppConstants.homeGreyIcon,
                AppConstants.homeSelectedIcon, 0),
            const SizedBox(height: 20),
            _buildNavItem(context, AppConstants.storageGreyIcon,
                AppConstants.storageSelectedIcon, 1),
            const SizedBox(height: 20),
            _buildNavItem(context, AppConstants.analyticsGreyIcon,
                AppConstants.analyticsSelectedIcon, 2),
            const SizedBox(height: 20),
            _buildNavItem(context, AppConstants.settingsGreyIcon,
                AppConstants.settingsSelectedIcon, 3),
          ],
        ),
      ),
    );
  }

  /// Builds a navigation item for the vertical navigation bar.
  ///
  /// This method uses the provided asset paths for the grey and selected icons,
  /// and highlights the selected icon based on the `currentIndex`.
  ///
  /// - [context]: The current build context.
  /// - [greyIconAsset]: The asset path for the grey icon (unselected state).
  /// - [selectedIconAsset]: The asset path for the selected icon (highlighted state).
  /// - [index]: The index of this navigation item, used to compare with [currentIndex].
  ///
  /// Returns a [Widget] that represents a navigation item with an icon button.
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
              onTabSelected(index); // Pass the index to the parent widget
            },
          ),
        ),
      ],
    );
  }
}
