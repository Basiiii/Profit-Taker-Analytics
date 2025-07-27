import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:profit_taker_analyzer/constants/preferences/shared_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPopup extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingPopup({super.key, required this.onFinish});

  @override
  OnboardingPopupState createState() => OnboardingPopupState();
}

class OnboardingPopupState extends State<OnboardingPopup> {
  int _currentStep = 0;

  // List of steps without translation
  final List<Map<String, dynamic>> _steps = [
    {"image": "assets/images/welcome.png", "textKey": "onboarding.welcome"},
    {
      "image": "assets/images/navigation.png",
      "textKey": "onboarding.navigation"
    },
    {
      "image": "assets/images/screenshot.png",
      "textKey": "onboarding.screenshot"
    },
    {"image": "assets/images/main_nav.png", "textKey": "onboarding.main_nav"},
    {"image": "assets/images/welcome.png", "textKey": "onboarding.final"}
  ];

  void _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SharedPrefsKeys.hasSeenOnBoarding, true);
      widget.onFinish();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String currentStepText =
        FlutterI18n.translate(context, _steps[_currentStep]["textKey"]);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Apply rounded corners
      ),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        // Ensures the rounded corners are respected
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dark overlay background
            Positioned.fill(
              child: Container(
                color: theme.colorScheme.surfaceTint.withAlpha(180),
              ),
            ),

            // Centered popup content
            Container(
              width: 500,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(16), // Ensure rounded corners
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    _steps[_currentStep]["image"],
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentStepText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button
                      ElevatedButton(
                        onPressed: _currentStep > 0 ? _previousStep : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Previous"),
                      ),

                      // Next / Got it Button
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentStep == _steps.length - 1
                              ? "Got it!"
                              : "Next",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
