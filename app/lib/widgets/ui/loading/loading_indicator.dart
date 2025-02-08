import 'package:flutter/material.dart';

/// A widget that displays a centered loading indicator.
///
/// This widget consists of a [CircularProgressIndicator] wrapped in a [Center]
/// widget to ensure it is displayed in the middle of the screen.
///
/// ### Example Usage:
/// ```dart
/// LoadingIndicator()
/// ```
///
/// This is useful for displaying a loading state in an application.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
