import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/screens/home/utils/translations.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/edit_run_name.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:profit_taker_analyzer/services/screenshot_service.dart';
import 'package:profit_taker_analyzer/utils/screenshot.dart';
import 'package:profit_taker_analyzer/widgets/dialogs.dart';
import 'package:profit_taker_analyzer/widgets/text_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rust_core/rust_core.dart';

class RunTitle extends StatelessWidget {
  final RunModel run;
  final bool mostRecentRun;

  const RunTitle({
    super.key,
    required this.run,
    required this.mostRecentRun,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final runService = context.watch<RunNavigationService>();
    final screenshotService = context.read<ScreenshotService>();
    final String runName = run.runName;

    return Row(
      children: [
        Flexible(
          child: titleText(
            getRunTitle(
                context,
                mostRecentRun,
                run.isSoloRun,
                run.squadMembers.map((member) => member.memberName).toList(),
                locale),
            20,
            FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (locale.languageCode != 'tr')
          titleText(
            " ${FlutterI18n.translate(context, "home.named")} ",
            20,
            FontWeight.w500,
          ),
        titleText("\"$runName\"", 20, FontWeight.w500),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _handleEditName(context),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () => _handleScreenshotCopy(context, screenshotService),
        ),
        IconButton(
          icon: const Icon(Icons.sticky_note_2_outlined, size: 20),
          onPressed: () => _handleCopyRunAsText(context),
        ),
        if (runService.currentRun?.isBuggedRun ?? false)
          _buildWarningIcon(context, true),
        if (runService.currentRun?.isAbortedRun ?? false)
          _buildWarningIcon(context, false),
      ],
    );
  }

  void _handleEditName(BuildContext context) {
    TextEditingController controller = TextEditingController(text: run.runName);

    editRunNameDialog(
      context,
      controller,
      FlutterI18n.translate(context, "alerts.name_title"),
      FlutterI18n.translate(context, "alerts.name_title"),
      FlutterI18n.translate(context, "buttons.cancel"),
      FlutterI18n.translate(context, "buttons.ok"),
      (newName) {
        // Update the run name in DB
        updateRunName(runId: run.runId, newName: newName);

        // Get the RunNavigationService from the context
        final runService =
            Provider.of<RunNavigationService>(context, listen: false);

        // Call the updateCurrentRunName function from the RunNavigationService
        runService.updateCurrentRunName(newName);
      },
    );
  }

  void _handleScreenshotCopy(BuildContext context, ScreenshotService service) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    captureScreenshot(service.controller).then((status) {
      if (context.mounted) {
        final message = FlutterI18n.translate(context, "screenshot.$status");
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  void _handleCopyRunAsText(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final textToCopy = getPrettyPrintedRun(runModel: run);
      Clipboard.setData(ClipboardData(text: textToCopy));

      if (context.mounted) {
        final message = FlutterI18n.translate(context, "copy_run_text.success");
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final message = FlutterI18n.translate(context, "copy_run_text.error");
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  Widget _buildWarningIcon(BuildContext context, bool isBugged) {
    return IconButton(
      icon: Icon(
        Icons.warning,
        color: isBugged ? Theme.of(context).colorScheme.error : Colors.yellow,
      ),
      onPressed: () => showBuggedRunWarningDialog(
        context,
        FlutterI18n.translate(context, "errors.error"),
        FlutterI18n.translate(
          context,
          isBugged ? "errors.bugged_run_warning" : "errors.aborted_run_warning",
        ),
      ),
    );
  }
}
