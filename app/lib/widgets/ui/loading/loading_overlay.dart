import 'package:flutter/material.dart';

/// A widget that overlays a loading indicator on top of its child.
///
/// The `LoadingOverlay` widget is designed to wrap another widget and display
/// a loading indicator when necessary. It provides methods to show and hide
/// the loading overlay dynamically.
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key, required this.child});

  /// The child widget that is wrapped by the loading overlay.
  final Widget child;

  /// Returns the state of the nearest ancestor [LoadingOverlayState].
  static LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<LoadingOverlayState>()!;
  }

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();
}

/// The state for the [LoadingOverlay] widget.
///
/// This state manages the visibility of the loading overlay and provides
/// methods to show and hide it.
class LoadingOverlayState extends State<LoadingOverlay> {
  bool _isLoading = false;

  /// Shows the loading overlay.
  void show() {
    setState(() {
      _isLoading = true;
    });
  }

  /// Hides the loading overlay.
  void hide() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
            ),
          ),
      ],
    );
  }
}
