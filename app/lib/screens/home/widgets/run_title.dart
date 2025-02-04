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
  final bool showBestRunText;

  const RunTitle({
    super.key,
    required this.run,
    required this.mostRecentRun,
    required this.showBestRunText,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final runService = context.watch<RunNavigationService>();
    final screenshotService = context.read<ScreenshotService>();
    final String runName = run.runName;
    final isFavorited = checkRunFavorite(runId: run.runId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Main text and icons wrapped together
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Text parts
                    titleText(
                      getRunTitle(
                          context,
                          mostRecentRun,
                          run.isSoloRun,
                          run.squadMembers
                              .map((member) => member.memberName)
                              .toList(),
                          locale),
                      20,
                      FontWeight.w500,
                    ),
                    if (locale.languageCode != 'tr')
                      titleText(
                        " ${FlutterI18n.translate(context, "home.named")} ",
                        20,
                        FontWeight.w500,
                      ),
                    titleText("\"$runName\"", 20, FontWeight.w500),

                    // Icons placed right after the text within the Wrap
                    IconButton(
                      icon: const Icon(Icons.edit, size: 22),
                      onPressed: () => _handleEditName(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 22),
                      onPressed: () =>
                          _handleScreenshotCopy(context, screenshotService),
                    ),
                    IconButton(
                      icon: const Icon(Icons.description_outlined, size: 24),
                      onPressed: () => _handleCopyRunAsText(context),
                    ),
                    IconButton(
                      icon: isFavorited
                          ? const Icon(Icons.star_rounded, size: 26)
                          : const Icon(Icons.star_outline_rounded, size: 26),
                      onPressed: () => _handleToggleFavorite(
                          context, isFavorited, run.runId),
                    ),
                    if (runService.currentRun?.isBuggedRun ?? false)
                      _buildWarningIcon(context, true),
                    if (runService.currentRun?.isAbortedRun ?? false)
                      _buildWarningIcon(context, false),
                  ],
                ),
              );
            },
          ),
        ),
        // "Best run yet!" text aligned to the right
        if (showBestRunText) ...[
          const SizedBox(width: 16),
          const Text(
            "Best run yet!", // hardcoded because it's famous within PT community
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.purple),
          ),
          const SizedBox(width: 62),
        ],
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

  void _handleToggleFavorite(
      BuildContext context, bool isFavorited, int runId) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isSuccess = isFavorited == false
        ? markRunAsFavorite(runId: runId)
        : removeRunFromFavorites(runId: runId);

    if (!context.mounted) return;

    final messageKey = isSuccess
        ? (isFavorited ? "remove_favorite.success" : "mark_favorite.success")
        : (isFavorited ? "remove_favorite.error" : "mark_favorite.error");

    final message = FlutterI18n.translate(context, messageKey);
    scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));

    // Get the RunNavigationService from the context
    final runService =
        Provider.of<RunNavigationService>(context, listen: false);

    // Call the forceUIRefresh function from the RunNavigationService
    runService.forceUIRefresh();
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
