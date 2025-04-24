import 'package:flutter/material.dart';
import 'dart:async';

/// Manages smooth transitions to prevent frame skipping and jank
///
/// This utility helps manage transitions between screens and animations
/// to ensure they don't overwhelm the rendering pipeline
class SmoothTransitionManager {
  static const Duration _defaultDelay = Duration(milliseconds: 16); // One frame
  static const Duration _heavyTransitionDelay = Duration(milliseconds: 300);
  
  /// Execute a navigation with proper timing to prevent jank
  static Future<T?> navigateWithProperTiming<T>({
    required BuildContext context,
    required Route<T> route,
    bool isHeavyTransition = false,
  }) async {
    // Wait for the current frame to complete
    await Future.delayed(_defaultDelay);
    
    if (isHeavyTransition) {
      // For heavy transitions, wait a bit longer
      await Future.delayed(_heavyTransitionDelay);
    }
    
    if (!context.mounted) return null;
    
    return Navigator.of(context).push(route);
  }
  
  /// Execute a callback after proper timing delay
  static Future<void> executeWithProperTiming({
    required VoidCallback callback,
    bool isHeavyOperation = false,
  }) async {
    await Future.delayed(
      isHeavyOperation ? _heavyTransitionDelay : _defaultDelay
    );
    callback();
  }
  
  /// Wrap a transition with proper frame scheduling
  static Widget wrapTransition({
    required Widget child,
    Duration? delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: delay ?? _defaultDelay,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Create a delayed animation to prevent jank
  static Widget createDelayedAnimation({
    required Widget child,
    Duration? delay,
    bool reverse = false,
  }) {
    return FutureBuilder(
      future: Future.delayed(delay ?? _defaultDelay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}
