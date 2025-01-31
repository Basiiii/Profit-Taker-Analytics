import 'package:flutter/material.dart';
import 'package:rust_core/rust_core.dart';

Future<void> main() async {
  await RustLib.init();

  Run x = getRunFromDb(runId: 1, dbPath: 'C:/test.db');
  print(x);

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
