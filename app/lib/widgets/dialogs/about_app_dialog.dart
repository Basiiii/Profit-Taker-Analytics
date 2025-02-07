import 'package:flutter/material.dart';

/// Displays an about dialog with information about the app.
///
/// This function shows a dialog with a title of "About", and a small easter egg.
/// The user can close the dialog by pressing the "OK" button.
void showAboutAppDialog(
    BuildContext context, String title, String content, String okButton) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(okButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
