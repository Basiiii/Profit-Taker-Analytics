import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rust_core/rust_core.dart';

Future<bool> deleteRun(BuildContext context, int runId) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  // Show a confirmation dialog before deleting
  final bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(FlutterI18n.translate(context, "alerts.delete_title")),
        content: Text(FlutterI18n.translate(context, "alerts.delete_message")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(FlutterI18n.translate(context, "common.cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(FlutterI18n.translate(context, "common.delete")),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    // Call the Rust function to delete the run
    final DeleteRunResult result = deleteRunFromDb(runId: runId);

    if (result.success) {
      // Show success message
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content:
                  Text(FlutterI18n.translate(context, "delete_run.success"))),
        );
      }
      return true; // Return true to indicate success
    } else {
      // Show error message
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.error ??
                FlutterI18n.translate(context, "delete_run.error")),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; // Return false to indicate failure
    }
  }

  return false; // Return false if deletion was canceled
}
