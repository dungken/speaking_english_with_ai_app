import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Provides platform detection utilities for implementing platform-aware code
class PlatformChecker {
  /// Returns true if the app is running on the web platform
  static bool get isWeb => kIsWeb;
  
  /// Returns true if the app is running on Android
  static bool get isAndroid => !kIsWeb && io.Platform.isAndroid;
  
  /// Returns true if the app is running on iOS
  static bool get isIOS => !kIsWeb && io.Platform.isIOS;
  
  /// Returns true if the app is running on macOS
  static bool get isMacOS => !kIsWeb && io.Platform.isMacOS;
  
  /// Returns true if the app is running on Windows
  static bool get isWindows => !kIsWeb && io.Platform.isWindows;
  
  /// Returns true if the app is running on Linux
  static bool get isLinux => !kIsWeb && io.Platform.isLinux;
  
  /// Returns true if the app is running on a mobile platform
  static bool get isMobile => !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);
  
  /// Returns true if the app is running on a desktop platform
  static bool get isDesktop => !kIsWeb && (io.Platform.isMacOS || io.Platform.isWindows || io.Platform.isLinux);
}