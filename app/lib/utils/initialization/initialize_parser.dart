import 'package:flutter/foundation.dart';
import 'package:rust_core/rust_core.dart';

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
