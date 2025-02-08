import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:profit_taker_analyzer/constants/preferences/shared_prefs_keys.dart';
import 'package:profit_taker_analyzer/screens/home/ui/no_runs_available.dart';
import 'package:profit_taker_analyzer/screens/home/ui/error_view.dart';
import 'package:profit_taker_analyzer/screens/home/ui/home_content.dart';
import 'package:profit_taker_analyzer/screens/home/widgets/onboarding_popup.dart';
import 'package:profit_taker_analyzer/services/input/action_keys.dart';
import 'package:profit_taker_analyzer/widgets/ui/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:profit_taker_analyzer/services/run_navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A StatefulWidget that displays the home screen of the application.
///
/// The home screen shows the current run data, navigation controls, and manages
/// the state for loading, errors, and the display of run content. It listens for keyboard events
/// to allow navigation between runs using action keys and mouse scroll events.
///
/// Returns:
/// A [HomeScreen] widget displaying the home content, error view, or no runs available message based on the app state.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The state for [HomeScreen], managing the initialization, loading of action keys, and periodic updates.
///
/// This class handles loading the saved action keys, initializing the run service, and managing the state for
/// loading, error, or content display. It listens for key and pointer events to navigate between runs.
///
/// Instance variables:
/// - [_scaffoldKey]: The global key for the scaffold used in the home screen.
/// - [_runService]: An instance of [RunNavigationService] used to manage the app's run navigation.
///
/// Methods:
/// - [initState]: Initializes the run service and starts periodic updates.
/// - [dispose]: Stops the periodic updates when the screen is disposed.
/// - [_loadKeys]: Loads the saved action keys from SharedPreferences and triggers a rebuild.
class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late RunNavigationService _runService;

  @override
  void initState() {
    super.initState();

    _loadKeys();

    _checkOnboarding();

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

  /// Checks if onboarding has been seen and shows it if necessary.
  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        prefs.getBool(SharedPrefsKeys.hasSeenOnBoarding) ?? false;

    if (!hasSeenOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOnboarding();
      });
    }
  }

  void _showOnboarding() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must complete onboarding
      builder: (context) => OnboardingPopup(
        onFinish: () {
          Navigator.of(context).pop(); // Close overlay when finished
        },
      ),
    );
  }

  /// Loads the saved action keys from SharedPreferences and updates the state accordingly.
  ///
  /// This method retrieves the saved action keys (up and down) and triggers a rebuild to apply the updated keys.
  ///
  /// Parameters:
  /// None.
  ///
  /// Returns:
  /// A [Future<void>] that completes when the keys have been loaded and the state has been updated.
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
