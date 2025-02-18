import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/screens/home/utils/translations.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/bugged_run_dialog.dart';
import 'package:profit_taker_analyzer/widgets/dialogs/edit_run_name_dialog.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:profit_taker_analyzer/services/screenshot_service.dart';
import 'package:profit_taker_analyzer/utils/media/screenshot.dart';
import 'package:profit_taker_analyzer/utils/text/text_utils.dart';
import 'package:provider/provider.dart';
import 'package:rust_core/rust_core.dart';

/// A widget that displays the title section for a specific run.
///
/// This widget presents information about the run, including its title,
/// whether it's the most recent run, options to edit the run name,
/// toggle favorites, copy run data, and handle screenshots.
/// It also shows warnings if the run is bugged or aborted.
///
/// The [RunTitle] widget includes icons for user actions, such as
/// editing the run name, copying the run as text, marking the run as a favorite,
/// and capturing a screenshot. It also displays a "Best run yet!" message
/// when appropriate.
///
/// [run] The [RunModel] that contains the information about the specific run.
/// [mostRecentRun] A boolean that determines if the current run is the most recent.
/// [showBestRunText] A boolean that controls the display of the "Best run yet!" text.
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
                    buildSmallTitle(getRunTitle(
                        context,
                        mostRecentRun,
                        run.isSoloRun,
                        run.squadMembers
                            .map((member) => member.memberName)
                            .toList(),
                        locale)),
                    if (locale.languageCode != 'tr')
                      buildSmallTitle(
                          " ${FlutterI18n.translate(context, "home.named")} "),
                    buildSmallTitle("\"$runName\""),

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

  /// Opens a dialog to edit the name of the current run.
  ///
  /// The user can provide a new name for the run, and this method updates
  /// the run name in the database and updates the UI accordingly.
  void _handleEditName(BuildContext context) {
    TextEditingController controller = TextEditingController(text: run.runName);

    editRunNameDialog(
      context,
      controller,
      FlutterI18n.translate(context, "alerts.name_title"),
      FlutterI18n.translate(context, "alerts.name_title"),
      FlutterI18n.translate(context, "common.cancel"),
      FlutterI18n.translate(context, "common.ok"),
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

  /// Captures a screenshot of the current screen and provides feedback.
  ///
  /// This method interacts with the ScreenshotService to capture a screenshot
  /// and displays a message using the [ScaffoldMessenger] to notify the user
  /// whether the screenshot was successfully captured or failed.
  void _handleScreenshotCopy(BuildContext context, ScreenshotService service) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    captureScreenshot(service.controller).then((status) {
      if (context.mounted) {
        final message = FlutterI18n.translate(context, "screenshot.$status");
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  /// Copies the current run's details as a formatted text to the clipboard.
  ///
  /// If successful, a success message is displayed using the [ScaffoldMessenger].
  /// If an error occurs during the copying process, an error message is displayed.
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

  /// Toggles the favorite status of the current run.
  ///
  /// If the run is not marked as a favorite, it is marked as one; otherwise, it is removed
  /// from favorites. A snack bar notification is displayed based on the success or failure of the action.
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

  /// Builds and shows a warning icon when the run is either bugged or aborted.
  ///
  /// The icon color changes based on whether the run is bugged (red) or aborted (yellow).
  /// A tap on the icon shows a warning dialog for the respective error type.
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
        FlutterI18n.translate(context, "common.ok"),
      ),
    );
  }
}
