import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
          : FlutterI18n.translate(context, "home.last_run_with") +
              formattedPlayerList;
    }
  }
}

// Helper function to format the player list
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

// Function to show warnings for bugged/aborted runs
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
