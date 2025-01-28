import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/home_header.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:provider/provider.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(scaffoldKey: GlobalKey<ScaffoldState>()),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    FlutterI18n.translate(context, "errors.load_failed"),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<RunNavigationService>().initialize(),
                    child:
                        Text(FlutterI18n.translate(context, "buttons.retry")),
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
