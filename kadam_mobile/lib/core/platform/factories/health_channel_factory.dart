import 'dart:io';
import 'package:flutter/foundation.dart';
import '../channels/health_channel.dart';
import '../channels/health_connect_channel.dart';
import '../channels/mock_health_channel.dart';
import '../models/platform_capability.dart';

/// Factory for creating health channel instances based on platform
///
/// Usage:
/// ```dart
/// // Auto-detect platform
/// final channel = await HealthChannelFactory.create();
///
/// // Create specific platform
/// final channel = HealthChannelFactory.createForPlatform(HealthPlatform.healthConnect);
///
/// // Create mock for testing
/// final channel = HealthChannelFactory.createMock();
/// ```
class HealthChannelFactory {
  static HealthChannel? _cachedChannel;

  /// Create a health channel instance for the current platform
  ///
  /// Returns null if no compatible health platform is available
  static Future<HealthChannel?> create({
    bool forceNew = false,
    bool useMock = false,
  }) async {
    // Return cached instance if available
    if (!forceNew && _cachedChannel != null) {
      return _cachedChannel;
    }

    // Use mock in debug mode if specified
    if (useMock ||
        (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST'))) {
      _cachedChannel = createMock();
      debugPrint('🏥 [Factory] Created Mock Health Channel');
      return _cachedChannel;
    }

    // Detect platform and create appropriate channel
    HealthChannel? channel;

    if (Platform.isIOS) {
      // channel = await _createAppleHealthChannel();
    } else if (Platform.isAndroid) {
      channel = await _createHealthConnectChannel();
    } else {
      debugPrint(
          '⚠️ [Factory] Unsupported platform: ${Platform.operatingSystem}');
      // Fallback to mock for unsupported platforms
      channel = createMock();
    }

    _cachedChannel = channel;
    return channel;
  }

  /// Create a health channel for a specific platform
  ///
  /// This allows manual platform selection if multiple are available
  static HealthChannel createForPlatform(HealthPlatform platform) {
    switch (platform) {
      // case HealthPlatform.appleHealth:
      //   return AppleHealthChannel();

      case HealthPlatform.healthConnect:
        return HealthConnectChannel();

      case HealthPlatform.googleFit:
        // TODO: Implement Google Fit channel
        throw UnimplementedError('Google Fit not yet implemented');

      case HealthPlatform.samsungHealth:
        // Samsung Health data is accessed via Health Connect
        throw UnsupportedError('Use Health Connect for Samsung Health data');

      case HealthPlatform.fitbit:
        // TODO: Implement Fitbit channel
        throw UnimplementedError('Fitbit not yet implemented');

      case HealthPlatform.mock:
        return createMock();

      default:
        throw UnsupportedError('Platform $platform is not supported');
    }
  }

  /// Create a mock health channel for testing
  static MockHealthChannel createMock({
    bool isAvailable = true,
    bool hasPermissions = true,
    int todaySteps = 5000,
  }) {
    final mock = MockHealthChannel();
    mock.setAvailable(isAvailable);
    mock.setPermissions(hasPermissions);
    mock.setTodaySteps(todaySteps);
    return mock;
  }

  /// Get all available health channels for the current device
  ///
  /// Returns a list of channels that are actually available and functional
  static Future<List<HealthChannel>> getAvailableChannels() async {
    final List<HealthChannel> available = [];

    if (Platform.isIOS) {
      // final appleHealth = await _createAppleHealthChannel();
      // if (appleHealth != null) {
      //   available.add(appleHealth);
      // }
    } else if (Platform.isAndroid) {
      final healthConnect = await _createHealthConnectChannel();
      if (healthConnect != null) {
        available.add(healthConnect);
      }

      // TODO: Check for Google Fit as fallback
      // final googleFit = await _createGoogleFitChannel();
      // if (googleFit != null) {
      //   available.add(googleFit);
      // }
    }

    // Always add mock as fallback in debug mode
    if (kDebugMode && available.isEmpty) {
      available.add(createMock());
    }

    return available;
  }

  /// Check if a specific platform is available on the current device
  static Future<bool> isPlatformAvailable(HealthPlatform platform) async {
    try {
      final channel = createForPlatform(platform);
      return await channel.isAvailable();
    } catch (e) {
      debugPrint('⚠️ [Factory] Error checking platform $platform: $e');
      return false;
    }
  }

  /// Get the best available health channel for the current device
  ///
  /// Priority order:
  /// 1. iOS: Apple Health
  /// 2. Android: Health Connect (preferred)
  /// 3. Android: Google Fit (fallback)
  /// 4. Mock (for testing/unsupported platforms)
  static Future<HealthChannel> getBestAvailable() async {
    final channel = await create();

    if (channel != null) {
      return channel;
    }

    // Fallback to mock if nothing available
    debugPrint('⚠️ [Factory] No health platforms available, using mock');
    return createMock();
  }

  /// Reset the cached channel instance
  ///
  /// Call this when you want to force a new channel creation
  static void resetCache() {
    _cachedChannel = null;
    debugPrint('🔄 [Factory] Channel cache reset');
  }

  /// Dispose the cached channel and clean up resources
  static Future<void> dispose() async {
    if (_cachedChannel != null) {
      await _cachedChannel!.disconnect();
      _cachedChannel = null;
      debugPrint('🗑️ [Factory] Channel disposed');
    }
  }

  // Private helper methods

  // static Future<HealthChannel?> _createAppleHealthChannel() async {
  //   try {
  //     final channel = AppleHealthChannel();
  //     final isAvailable = await channel.isAvailable();

  //     if (isAvailable) {
  //       debugPrint('✅ [Factory] Apple Health available');
  //       return channel;
  //     } else {
  //       debugPrint('⚠️ [Factory] Apple Health not available');
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('❌ [Factory] Error creating Apple Health channel: $e');
  //     return null;
  //   }
  // }

  static Future<HealthChannel?> _createHealthConnectChannel() async {
    try {
      final channel = HealthConnectChannel();

      // Check if Health Connect is installed
      final isInstalled = await channel.isInstalled();
      if (!isInstalled) {
        debugPrint('⚠️ [Factory] Health Connect not installed');
        return null;
      }

      // Check if available
      final isAvailable = await channel.isAvailable();
      if (isAvailable) {
        debugPrint('✅ [Factory] Health Connect available');
        return channel;
      } else {
        final status = await channel.getSdkStatus();
        debugPrint(
            '⚠️ [Factory] Health Connect not available (status: $status)');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [Factory] Error creating Health Connect channel: $e');
      return null;
    }
  }
}

/// Exception thrown when a health platform is not supported
class UnsupportedPlatformException implements Exception {
  final String message;
  final HealthPlatform platform;

  UnsupportedPlatformException(this.platform)
      : message = 'Platform ${platform.displayName} is not supported';

  @override
  String toString() => 'UnsupportedPlatformException: $message';
}

/// Exception thrown when health platform detection fails
class PlatformDetectionException implements Exception {
  final String message;
  final dynamic originalError;

  PlatformDetectionException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'PlatformDetectionException: $message\nCaused by: $originalError';
    }
    return 'PlatformDetectionException: $message';
  }
}
