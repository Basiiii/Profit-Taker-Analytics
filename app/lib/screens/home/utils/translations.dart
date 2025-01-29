import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Returns the title for a run based on localization, run status, and player information.
///
/// This method generates a title for the run depending on whether it's the most recent run,
/// whether it's a solo run, and the list of players involved. The title is localized for different languages,
/// with specific formatting for Turkish and other locales.
///
/// Parameters:
/// - [context]: The build context used for localization.
/// - [mostRecentRun]: A boolean indicating whether the run is the most recent.
/// - [soloRun]: A boolean indicating whether the run is solo.
/// - [players]: A list of player names involved in the run.
/// - [currentLocale]: The current locale to adjust the title based on language.
///
/// Returns:
/// A [String] containing the localized title for the run.
String getRunTitle(
  BuildContext context,
  bool mostRecentRun,
  bool soloRun,
  List<String> players,
  Locale? currentLocale,
) {
  String formattedPlayerList = _formatPlayerList(players, context);

  if (currentLocale?.languageCode == 'tr') {
    return mostRecentRun
        ? FlutterI18n.translate(context, "home.last_run")
        : FlutterI18n.translate(context, "home.run");
  } else {
    if (mostRecentRun) {
      return soloRun
          ? FlutterI18n.translate(context, "home.last_run")
          : FlutterI18n.translate(context, "home.last_run_with") +
              formattedPlayerList;
    } else {
      return soloRun
          ? FlutterI18n.translate(context, "home.run")
          : FlutterI18n.translate(context, "home.run_with") +
              formattedPlayerList;
    }
  }
}

/// Formats a list of player names for display in a localized format.
///
/// The player list is formatted in a natural language style, where players are joined with commas,
/// and the last player is prefixed with a localized "and" (e.g., "Player1, Player2, and Player3").
///
/// Parameters:
/// - [players]: A list of player names to be formatted.
/// - [context]: The build context used for localization.
///
/// Returns:
/// A [String] containing the formatted player list.
String _formatPlayerList(List<String> players, BuildContext context) {
  if (players.isEmpty) {
    return '';
  } else if (players.length == 1) {
    return players.first;
  } else {
    String playersListStart = players.sublist(0, players.length - 1).join(', ');
    String playersListEnd = players.last;
    return "$playersListStart${FlutterI18n.translate(context, "home.and")}$playersListEnd";
  }
}

/// Displays a warning dialog for bugged or aborted runs.
///
/// This method checks if the run is bugged or aborted and triggers a warning dialog
/// accordingly. The dialog is shown using the provided callback function.
///
/// Parameters:
/// - [context]: The build context used to display the warning dialog.
/// - [isBuggedRun]: A boolean indicating whether the run is bugged.
/// - [isAbortedRun]: A boolean indicating whether the run is aborted.
/// - [errorTitle]: The title of the warning dialog.
/// - [buggedRunWarningMessage]: The message to be shown if the run is bugged.
/// - [abortedRunWarningMessage]: The message to be shown if the run is aborted.
/// - [showBuggedRunWarningDialog]: A callback function to display the warning dialog.
///
/// Returns:
/// None. This method triggers the warning dialog if necessary.
void showRunWarning(
  BuildContext context,
  bool isBuggedRun,
  bool isAbortedRun,
  String errorTitle,
  String buggedRunWarningMessage,
  String abortedRunWarningMessage,
  Function(BuildContext, String, String) showBuggedRunWarningDialog,
) {
  if (isBuggedRun) {
    showBuggedRunWarningDialog(context, errorTitle, buggedRunWarningMessage);
  } else if (isAbortedRun) {
    showBuggedRunWarningDialog(context, errorTitle, abortedRunWarningMessage);
  }
}
