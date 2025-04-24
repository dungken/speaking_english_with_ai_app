import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

/// Monitors app performance and frame timing
///
/// Helps identify performance bottlenecks and frame drops
class PerformanceMonitor {
  static bool _isMonitoring = false;
  static final List<int> _frameTimes = [];
  static const int _maxSamples = 60;
  static Timer? _reportTimer;
  
  /// Start performance monitoring
  static void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    
    // Monitor frame timing
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final duration = timing.totalSpan.inMilliseconds;
        _frameTimes.add(duration);
        
        // Keep only recent samples
        if (_frameTimes.length > _maxSamples) {
          _frameTimes.removeAt(0);
        }
        
        // Warn on janky frames (> 16ms for 60fps)
        if (duration > 16) {
          debugPrint('Performance: Janky frame detected: ${duration}ms');
        }
      }
    });
    
    // Report average performance every 5 seconds
    _reportTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_frameTimes.isNotEmpty) {
        final average = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
        final fps = 1000 / average;
        debugPrint('Performance: Average FPS: ${fps.toStringAsFixed(1)}');
        
        // Warn if FPS drops below 30
        if (fps < 30) {
          debugPrint('Performance: WARNING - Low FPS detected');
        }
      }
    });
  }
  
  /// Stop performance monitoring
  static void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    _reportTimer?.cancel();
    _reportTimer = null;
    _frameTimes.clear();
  }
  
  /// Log performance issue for specific operation
  static void logPerformanceIssue(String operation, String issue) {
    debugPrint('Performance Issue [$operation]: $issue');
  }
  
  /// Measure and log execution time for a function
  static Future<T> measureExecution<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      debugPrint('Performance [$operationName]: ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('Performance [$operationName]: Failed after ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }
}
