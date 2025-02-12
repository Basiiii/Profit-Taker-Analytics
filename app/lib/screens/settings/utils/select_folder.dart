import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/utils/system/folder.dart';
import 'package:rust_core/rust_core.dart';

/// Opens a folder selection dialog and initializes the JSON converter with the selected folder.
///
/// If a folder is selected, its path is printed (in debug mode), and the converter is initialized.
/// If no folder is selected, an error snackbar is displayed.
///
/// # Parameters:
/// - `context`: The [BuildContext] in which the operation is executed.
void selectFolder(BuildContext context) async {
  String? folderPath = await pickFolder();

  if (folderPath != null) {
    if (kDebugMode) {
      print(folderPath);
    }
    if (context.mounted) {
      await _initializeConverterWithHandling(context, folderPath);
    }
  } else {
    if (context.mounted) {
      _showErrorSnackbar(context);
    }
  }
}

/// Handles the initialization of the JSON converter and provides feedback to the user.
///
/// This function attempts to initialize the converter with the given storage folder.
/// If successful, it shows a success snackbar; otherwise, it catches and displays an error.
///
/// # Parameters:
/// - `context`: The [BuildContext] used to show the snackbar.
/// - `storageFolder`: The path to the folder where JSON files are stored.
///
/// # Errors:
/// - Displays an error message if the initialization fails.
Future<void> _initializeConverterWithHandling(
    BuildContext context, String storageFolder) async {
  try {
    await initializeConverter(storageFolder: storageFolder);

    if (context.mounted) {
      _showSuccessSnackbar(context);
    }
  } catch (error) {
    if (context.mounted) {
      _showErrorSnackbar(context,
          errorMessage: "Error initializing converter: $error");
    }
  }
}

/// Displays a success snackbar to indicate that the operation was completed successfully.
///
/// # Parameters:
/// - `context`: The [BuildContext] used to show the snackbar.
void _showSuccessSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(FlutterI18n.translate(context, "import_run.success")),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Displays an error snackbar with a default or custom error message.
///
/// # Parameters:
/// - `context`: The [BuildContext] used to show the snackbar.
/// - `errorMessage`: (Optional) A custom error message to display. If null, a default localized message is used.
void _showErrorSnackbar(BuildContext context, {String? errorMessage}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          errorMessage ?? FlutterI18n.translate(context, "import_run.error")),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
