import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/app/app_constants.dart';
import 'package:profit_taker_analyzer/utils/media/screenshot.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_actions.dart';
import 'package:profit_taker_analyzer/widgets/ui/headers/header_title.dart';
import 'package:screenshot/screenshot.dart';

class AnalyticsHeader extends StatelessWidget {
  final ScreenshotController screenshotController;
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
