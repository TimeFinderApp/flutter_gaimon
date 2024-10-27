import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
// Remove the unused import if not needed
// import 'package:gaimon/ahap_to_waveform_converter.dart';

class Gaimon {
  static const MethodChannel _channel = MethodChannel('gaimon');

  /// Check if the device supports haptic feedback
  static Future<bool> get canSupportsHaptic async {
    return await _channel.invokeMethod('canSupportsHaptic');
  }

  /// Prepare the haptic engine (should be called once)
  static Future<void> prepareHaptics() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('prepareHaptics');
    }
  }

  /// Create and cache the haptic pattern player
  static Future<void> createPlayer(String data) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('createPlayer', {'data': data});
    }
  }

  /// Play the cached haptic pattern
  static Future<void> playPattern() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('playPattern');
    }
  }

  /// Generate a custom pattern impact vibration (legacy method)
  static void patternFromData(String data) {
    if (Platform.isAndroid) {
      // Handle Android-specific implementation...
      // If you have Android-specific code, include it here.
    } else {
      // For iOS, call the 'pattern' method
      _channel.invokeMethod('pattern', {'data': data});
    }
  }

  // Existing methods for haptic feedback
  static void selection() => HapticFeedback.selectionClick();
  static void error() => _channel.invokeMethod('error');
  static void success() => _channel.invokeMethod('success');
  static void warning() => _channel.invokeMethod('warning');
  static void heavy() => HapticFeedback.heavyImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void light() => HapticFeedback.lightImpact();
  static void rigid() => _channel.invokeMethod('rigid');
  static void soft() => _channel.invokeMethod('soft');
}