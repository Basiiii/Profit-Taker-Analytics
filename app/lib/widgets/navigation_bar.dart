import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This class defines our custom navigation bar widget, used on left side.
class NavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

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
