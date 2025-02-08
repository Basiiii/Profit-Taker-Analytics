import 'package:flutter/material.dart';

/// Displays a contacts dialog with information about how to contact Basi.
///
/// This function shows a dialog with a title of "Contact Basi", and content describing
/// the author of the app and instructions for contacting. The user can close the
/// dialog by pressing the "OK" button.
void showContactsDialog(
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
