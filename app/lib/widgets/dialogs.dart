import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

/// Displays an error dialog to the user.
///
/// This method creates an AlertDialog with a title indicating that there was an error closing the parser.
/// The content of the dialog tells the user to try again. The dialog has two action buttons: 'FORCE QUIT' and 'Okay'.
///
/// Clicking the 'FORCE QUIT' button closes the dialog and forces the destruction of the window.
/// Clicking the 'Okay' button simply closes the dialog.
///
/// The method uses the `showDialog` function to display the AlertDialog. The `showDialog` function
/// requires a context and a builder function.
/// The builder function returns the AlertDialog to be displayed.
void showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
          title: const Text('There was an error closing parser.'),
          content: const Text('Please try again.'),
          actions: [
            TextButton(
                child: Text('FORCE QUIT',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                }),
            TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ]);
    },
  );
}

/// Displays a connection error dialog when the app fails to connect to the parser.
///
/// This function shows a dialog with a title of "Error!" and content advising the user
/// to restart the program. If the problem persists, they are instructed to contact Basi.
/// The user can close the dialog by pressing the "OK" button.
void showParserConnectionErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error!'),
        content: const Text(
            'The app cannot establish a connection to the parser.\nPlease restart the program.\n\nIf you continue with issues please contact Basi.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

/// Displays an about dialog with information about the app.
///
/// This function shows a dialog with a title of "About", and content describing
/// the author of the app and instructions for reaching out via Discord. The user
/// can close the dialog by pressing the "OK" button.
void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('About'),
        content: const Text(
            'Made with love by Basi.\nIf you found this, send me a DM\nof a mango on discord.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
