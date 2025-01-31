import 'package:flutter/material.dart';
import 'package:rust_core/rust_core.dart';

Future<void> main() async {
  await RustLib.init();

  print(initializeDb(path: 'C:/test.db'));
  print(getRunFromDb(runId: 1));

  print("Latest run ID: ${getLatestRunId()}");
  print("Earliest run ID: ${getEarliestRunId()}");

  print("Previous run ID: ${getPreviousRunId(currentRunId: 5)}");
  print("Next run ID: ${getNextRunId(currentRunId: 5)}");

  print(checkRunExists(runId: 1));
  print(checkRunExists(runId: 50));

  // print(simulateInsertRun());
  print(getRunFromDb(runId: 6));
  print(deleteRunFromDb(runId: 6));
  print(getRunFromDb(runId: 6));

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
