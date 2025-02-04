import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rust_core/rust_core.dart';

Future<void> main() async {
  await RustLib.init();

  try {
    initializeDb(
        path:
            'C:/Users/basi/Documents/GitHub/Profit-Taker-Analytics/app/build/windows/x64/runner/Debug/database/pta_database.db');
    if (kDebugMode) {
      print("Database initialized successfully!");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Failed to initialize database: $e");
    }
  }

  RunModel run = await getRunFromDb(runId: 1);
  print(getPrettyPrintedRun(runModel: run));

  RunModel run2 = await getRunFromDb(runId: 9);
  print(getPrettyPrintedRun(runModel: run2));

  // try {
  //   final runId = getLatestRunId();
  //   if (runId != null) {
  //     print("Latest run ID: $runId");
  //   } else {
  //     print("No runs found");
  //   }
  // } catch (e) {
  //   print("Failed to fetch latest run ID: $e");
  // }

  // try {
  //   final runId = getEarliestRunId();
  //   if (runId != null) {
  //     print("Earliest run ID: $runId");
  //   } else {
  //     print("No runs found");
  //   }
  // } catch (e) {
  //   print("Failed to fetch latest run ID: $e");
  // }

  // try {
  //   final runId = getPreviousRunId(currentRunId: 2);
  //   if (runId != null) {
  //     print("Next run ID: $runId");
  //   } else {
  //     print("No next run found");
  //   }
  // } catch (e) {
  //   print("Failed to fetch next run ID: $e");
  // }

  // try {
  //   final runId = getNextRunId(currentRunId: 2);
  //   if (runId != null) {
  //     print("Next run ID: $runId");
  //   } else {
  //     print("No next run found");
  //   }
  // } catch (e) {
  //   print("Failed to fetch next run ID: $e");
  // }

  // print(checkRunExists(runId: 1));
  // print(checkRunExists(runId: 50));

  // var result = deleteRunFromDb(runId: 3);
  // if (result.success) {
  //   print("Run deleted successfully");
  // } else {
  //   print("Error: ${result.error ?? "Unknown error"}");
  // }

  // var test = deleteRunFromDb(runId: 50);
  // if (test.success) {
  //   print("Run deleted successfully");
  // } else {
  //   print("Error: ${result.error ?? "Unknown error"}");
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
            // child: Text('Result: `${createDb(path: 'C:/test.db')}`'),
            ),
      ),
    );
  }
}
