import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/screens/home/utils/translations.dart';
import 'package:profit_taker_analyzer/utils/screenshot.dart';
import 'package:profit_taker_analyzer/widgets/dialogs.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:screenshot/screenshot.dart';

class RunTitle extends StatelessWidget {
  final String runName;
  final bool mostRecentRun;
  final bool soloRun;
  final bool isBuggedRun;
  final bool isAbortedRun;
  final List<String> players;
  final Locale? currentLocale;
  final ScreenshotController screenshotController;
  final String errorTitle;
  final String buggedRunWarningMessage;
  final String abortedRunWarningMessage;
  final Function(BuildContext, bool, bool, String, String, String, Function)
      showRunWarning;

  const RunTitle({
    super.key,
    required this.runName,
    required this.mostRecentRun,
    required this.soloRun,
    required this.isBuggedRun,
    required this.isAbortedRun,
    required this.players,
    required this.currentLocale,
    required this.screenshotController,
    required this.errorTitle,
    required this.buggedRunWarningMessage,
    required this.abortedRunWarningMessage,
    required this.showRunWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // "Your run"
        Flexible(
          child: titleText(
            getRunTitle(
              context,
              mostRecentRun,
              soloRun,
              players,
              currentLocale,
            ),
            20,
            FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // "called"
        if (currentLocale?.languageCode != 'tr')
          titleText(
            " ${FlutterI18n.translate(context, "home.named")} ",
            20,
            FontWeight.w500,
          ),
        // run name goes here
        titleText(
          "\"$runName\"",
          20,
          FontWeight.w500,
        ),
        // Icons
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () {
            var scaffoldMessenger = ScaffoldMessenger.of(context);
            captureScreenshot(screenshotController).then((status) {
              String message = messages[status] ?? 'Unknown status';
              scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
            });
          },
        ),
        if (isBuggedRun || isAbortedRun)
          IconButton(
            icon: Icon(
              Icons.warning,
              color: isBuggedRun
                  ? Theme.of(context).colorScheme.error
                  : Colors.yellow,
            ),
            onPressed: () => showRunWarning(
              context,
              isBuggedRun,
              isAbortedRun,
              errorTitle,
              buggedRunWarningMessage,
              abortedRunWarningMessage,
              showBuggedRunWarningDialog,
            ),
          ),
      ],
    );
  }
}
