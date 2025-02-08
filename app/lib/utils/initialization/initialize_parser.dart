import 'package:flutter/foundation.dart';
import 'package:rust_core/rust_core.dart';

/// Initializes the Profit Taker log parser and handles possible outcomes.
///
/// This function calls `initializeProfitTakerParser()` to set up the parser.
/// It then checks the result and logs any errors that may have occurred during initialization.
///
/// Possible outcomes:
/// - `success`: Parser initialized successfully.
/// - `environmentVariableError`: Issue with an environment variable.
/// - `fileOpenError`: Failed to open the log file.
/// - `fileSeekError`: Failed to seek within the log file.
/// - `threadSpawnError`: Failed to spawn the required thread.
/// - `unknownError`: An unspecified issue occurred.
///
/// If the app is in debug mode (`kDebugMode`), error messages will be printed to the console.
///
/// Example usage:
/// ```dart
/// initializeParser();
/// ```
///
/// No parameters or return value.
void initializeParser() {
  // Initialize the parser and store the outcome
  InitializeParserOutcome outcome = initializeProfitTakerParser();

  // Handle different outcomes
  switch (outcome) {
    case InitializeParserOutcome.success:
      if (kDebugMode) {
        print("Parser initialized successfully.");
      }
      break;

    case InitializeParserOutcome.environmentVariableError:
      if (kDebugMode) {
        print("Error: Issue with the environment variable.");
      }
      break;

    case InitializeParserOutcome.fileOpenError:
      if (kDebugMode) {
        print("Error: Could not open the log file.");
      }
      break;

    case InitializeParserOutcome.fileSeekError:
      if (kDebugMode) {
        print("Error: Could not seek the log file.");
      }
      break;

    case InitializeParserOutcome.threadSpawnError:
      if (kDebugMode) {
        print("Error: Could not spawn the thread.");
      }
      break;

    case InitializeParserOutcome.unknownError:
      if (kDebugMode) {
        print("Error: Unknown issue occurred during parser initialization.");
      }
      break;
  }
}
