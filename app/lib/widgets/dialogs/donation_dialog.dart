import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/constants/app_links.dart';
import 'package:profit_taker_analyzer/utils/utils.dart';

/// Displays a dialog with information about donating to Basi.
///
/// This function shows a dialog with a title of "Donations", and content describing
/// the author of the app and reasonings for donations. The user can close the
/// dialog by pressing the "OK" button.
void showDonationDialog(BuildContext context, String title, String main,
    String donatePaypalButton, String okayText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(main),
        actions: <Widget>[
          TextButton(
            child: Text(donatePaypalButton),
            onPressed: () {
              launchURL(AppLinks.basiPaypal);
            },
          ),
          TextButton(
            child: Text(okayText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
