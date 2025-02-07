import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/storage/model/run_list_model.dart';
import 'package:rust_core/rust_core.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

Future<bool> toggleFavorite(BuildContext context,
    List<RunListItemCustom> runItems, RunListItemCustom run) async {
  final previousState = run.isFavorite;

  // Optimistically update the UI
  final updatedRun = run.copyWith(isFavorite: !previousState);
  runItems[runItems.indexOf(run)] = updatedRun;

  // Call the API to mark/unmark as favorite
  final isSuccess = updatedRun.isFavorite
      ? markRunAsFavorite(runId: run.id)
      : removeRunFromFavorites(runId: run.id);

  if (isSuccess) {
    // Show success message
    final messageKey = updatedRun.isFavorite
        ? "mark_favorite.success"
        : "remove_favorite.success";
    final message = FlutterI18n.translate(context, messageKey);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    return true; // Return true to indicate success
  } else {
    // Revert UI state in case of failure
    runItems[runItems.indexOf(updatedRun)] = run;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite')));
    return false; // Return false to indicate failure
  }
}
