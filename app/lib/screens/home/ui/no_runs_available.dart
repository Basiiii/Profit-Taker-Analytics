import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/home_header.dart';

/// A StatelessWidget that displays a message when no runs are available.
///
/// This view shows an icon indicating that there are no runs, along with an error message
/// and a suggestion to start a new run. The message is localized using [FlutterI18n].
///
/// Returns:
/// A [NoRunsAvailable] widget displaying an icon, error message, and instructions to start a new run.
class NoRunsAvailable extends StatelessWidget {
  const NoRunsAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, top: 30),
      child: Column(
        children: [
          HomeHeader(
            scaffoldKey: GlobalKey<ScaffoldState>(),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_empty, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    FlutterI18n.translate(context, "errors.no_runs"),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    FlutterI18n.translate(context, "errors.start_new_run"),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
