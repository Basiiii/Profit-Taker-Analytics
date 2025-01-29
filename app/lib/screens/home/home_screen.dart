import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:profit_taker_analyzer/screens/home/ui/no_runs_available.dart';
import 'package:profit_taker_analyzer/screens/home/ui/error_view.dart';
import 'package:profit_taker_analyzer/screens/home/ui/home_content.dart';
import 'package:profit_taker_analyzer/utils/action_keys.dart';
import 'package:profit_taker_analyzer/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late RunNavigationService _runService;

  @override
  void initState() {
    super.initState();

    _loadKeys();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runService = Provider.of<RunNavigationService>(
        context,
        listen: false,
      );
      _runService.initialize();
      _runService.startPeriodicUpdate();
    });
  }

  @override
  void dispose() {
    _runService.stopPeriodicUpdate();
    super.dispose();
  }

  // Load the saved keys from SharedPreferences
  Future<void> _loadKeys() async {
    ActionKeyManager.upActionKey =
        await ActionKeyManager.loadUpActionKey() ?? LogicalKeyboardKey.arrowUp;
    ActionKeyManager.downActionKey =
        await ActionKeyManager.loadDownActionKey() ??
            LogicalKeyboardKey.arrowDown;
    setState(() {}); // Trigger a rebuild to use the updated keys
  }

  @override
  Widget build(BuildContext context) {
    final runService =
        Provider.of<RunNavigationService>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: KeyboardListener(
        focusNode: FocusNode(), // Needed to listen for keyboard events
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == ActionKeyManager.upActionKey) {
              runService.navigateToNextRun();
            } else if (event.logicalKey == ActionKeyManager.downActionKey) {
              runService.navigateToPreviousRun();
            }
          }
        },
        child: Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent) {
              if (event.scrollDelta.dy < 0) {
                runService.navigateToNextRun();
              } else if (event.scrollDelta.dy > 0) {
                runService.navigateToPreviousRun();
              }
            }
          },
          child: Consumer<RunNavigationService>(
            builder: (context, service, child) {
              if (service.isLoading) return const LoadingIndicator();
              if (service.currentRun == null) return const NoRunsAvailable();
              if (service.hasError) return const ErrorView();

              return HomeContent(runData: service.currentRun!);
            },
          ),
        ),
      ),
    );
  }
}
