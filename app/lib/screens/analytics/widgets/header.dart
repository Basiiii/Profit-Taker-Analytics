import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:profit_taker_analyzer/utils/media/screenshot.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_actions.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_title.dart';
import 'package:screenshot/screenshot.dart';

/// A widget representing the header of the analytics screen.
///
/// The header contains the application title and actions like taking a screenshot
/// and refreshing the average data. The screenshot is captured using the
/// [ScreenshotController] passed as a parameter.
class AnalyticsHeader extends StatelessWidget {
  /// The controller used for capturing screenshots.
  final ScreenshotController screenshotController;

  /// A callback function to fetch the average data when triggered.
  final VoidCallback fetchAverageData;

  const AnalyticsHeader({
    super.key,
    required this.screenshotController,
    required this.fetchAverageData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const HeaderTitle(title: AppConstants.appName),
        HeaderActions(
          actions: [
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                var scaffoldMessenger = ScaffoldMessenger.of(context);
                captureScreenshot(screenshotController).then((status) {
                  String message = messages[status] ?? 'Unknown status';
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                });
              },
            ),
            IconButton(
              onPressed: fetchAverageData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    );
  }
}
