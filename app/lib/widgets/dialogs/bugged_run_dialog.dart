import 'package:flutter/material.dart';

/// Shows a dialog warning about a bugged run.
///
/// This method displays a dialog with a warning message about a bugged run.
///
/// Parameters:
///   - context: The build context.
///   - errorText: The text content of the dialog.
///   - errorTitle: The title of the dialog.
void showBuggedRunWarningDialog(
    BuildContext context, String title, String content, String okButton) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ]);
      });
}
