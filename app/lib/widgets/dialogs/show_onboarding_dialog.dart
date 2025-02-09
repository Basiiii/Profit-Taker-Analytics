import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/onboarding_popup.dart';

/// Shows an onboarding popup dialog.
///
/// This function displays an [OnboardingPopup] dialog on top of the current screen.
/// The dialog can either be dismissible by tapping outside the dialog or not,
/// depending on the [dismissible] parameter.
///
/// Parameters:
/// - [context]: The [BuildContext] in which the dialog should be displayed.
///   Typically passed from a widget's `BuildContext`.
/// - [dismissible]: A boolean value that determines whether the dialog can
///   be dismissed by tapping outside of it. If `true`, tapping outside will
///   close the dialog; otherwise, it won't be dismissed by tapping outside.
///
/// The dialog contains an [OnboardingPopup] widget, and when the onboarding is
/// finished, the dialog is closed using [Navigator.of(context).pop()].
void showOnboardingDialog(BuildContext context, bool dismissible) {
  showDialog(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) => OnboardingPopup(
      onFinish: () {
        Navigator.of(context).pop();
      },
    ),
  );
}
