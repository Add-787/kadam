import 'package:flutter/foundation.dart';
import '../channels/health_channel.dart';
import '../channels/health_connect_channel.dart';
import '../factories/health_channel_factory.dart';
import '../models/platform_capability.dart';

/// Service that automatically detects and manages the single available health platform
///
/// The service will automatically select:
/// - iOS: Apple Health (if available)
/// - Android: Health Connect (if available)
/// - Debug/Test: Mock channel
///
/// There is NO manual platform selection - the service picks the best available option.
class HealthPlatformService {
  HealthChannel? _channel;
  bool _isInitialized = false;
  PlatformCapability? _capability;

  /// Get the active health channel (auto-selected)
  HealthChannel? get channel => _channel;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get the platform that was automatically detected
  HealthPlatform? get detectedPlatform => _channel?.platform;

  /// Get the display name of the active platform
  String get platformName => _channel?.platform.displayName ?? 'None';

  /// Get the platform capability information
  PlatformCapability? get capability => _capability;

  /// Initialize the service - automatically detects and selects platform
  ///
  /// No user input required - the service picks the only available option
  Future<void> initialize({bool useMock = false}) async {
    if (_isInitialized && !useMock) {
      debugPrint('✅ [Service] Already initialized with $platformName');
      return;
    }

    try {
      if (useMock) {
        // Use mock for testing
        _channel = HealthChannelFactory.createMock();
        _capability = await _channel!.getCapabilities();
        _isInitialized = true;
        debugPrint('🏥 [Service] Initialized with Mock channel');
        return;
      }

      // Automatically detect and create the appropriate channel
      _channel = await HealthChannelFactory.create();

      if (_channel == null) {
        debugPrint('⚠️ [Service] No health platform available on this device');

        // Fallback to mock in debug mode
        if (kDebugMode) {
          _channel = HealthChannelFactory.createMock();
          _capability = await _channel!.getCapabilities();
          debugPrint('🏥 [Service] Using mock channel as fallback');
        }
      } else {
        // Get capability information
        _capability = await _channel!.getCapabilities();
        debugPrint('✅ [Service] Initialized with $platformName');
        debugPrint('   Available: ${_capability?.isAvailable}');
        debugPrint('   Authorized: ${_capability?.isAuthorized}');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ [Service] Initialization error: $e');

      // Fallback to mock on error (in debug mode)
      if (kDebugMode) {
        _channel = HealthChannelFactory.createMock();
        _capability = await _channel!.getCapabilities();
        _isInitialized = true;
        debugPrint('🏥 [Service] Using mock channel due to error');
      } else {
        rethrow;
      }
    }
  }

  /// Check if a health platform is available on this device
  bool get hasHealthPlatform => _channel != null;

  /// Check if the platform is available and functional
  Future<bool> isPlatformAvailable() async {
    if (_channel == null) return false;

    try {
      return await _channel!.isAvailable();
    } catch (e) {
      debugPrint('❌ [Service] Error checking availability: $e');
      return false;
    }
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    if (_channel == null) {
      debugPrint('⚠️ [Service] No channel available');
      return false;
    }

    try {
      return await _channel!.hasPermissions();
    } catch (e) {
      debugPrint('❌ [Service] Error checking permissions: $e');
      return false;
    }
  }

  /// Request permissions from the user
  Future<bool> requestPermissions({List<String>? dataTypes}) async {
    if (_channel == null) {
      debugPrint('⚠️ [Service] No channel available');
      return false;
    }

    try {
      debugPrint('🔐 [Service] Requesting permissions for $platformName');
      final granted = await _channel!.requestPermissions(dataTypes: dataTypes);

      if (granted) {
        // Update capability after granting permissions
        _capability = await _channel!.getCapabilities();
        debugPrint('✅ [Service] Permissions granted');
      } else {
        debugPrint('❌ [Service] Permissions denied');
      }

      return granted;
    } catch (e) {
      debugPrint('❌ [Service] Error requesting permissions: $e');
      return false;
    }
  }

  /// Get platform capabilities
  Future<PlatformCapability?> getCapabilities() async {
    if (_channel == null) return null;

    try {
      _capability = await _channel!.getCapabilities();
      return _capability;
    } catch (e) {
      debugPrint('❌ [Service] Error getting capabilities: $e');
      return null;
    }
  }

  /// Check if the service is ready to use (initialized + has permissions)
  Future<bool> isReady() async {
    if (!_isInitialized || _channel == null) return false;

    try {
      final capability = await getCapabilities();
      return capability?.isReady ?? false;
    } catch (e) {
      debugPrint('❌ [Service] Error checking ready state: $e');
      return false;
    }
  }

  /// Check if a specific data type is supported
  bool supportsDataType(String dataType) {
    return _capability?.supportsDataType(dataType) ?? false;
  }

  /// Get all supported data types
  List<String> get supportedDataTypes {
    return _capability?.supportedDataTypes ?? [];
  }

  /// Open platform settings (Health Connect or HealthKit)
  Future<void> openPlatformSettings() async {
    if (_channel == null) {
      debugPrint('⚠️ [Service] No channel available');
      return;
    }

    try {
      if (_channel is HealthConnectChannel) {
        await (_channel as HealthConnectChannel).openSettings();
      } else {
        debugPrint(
            '⚠️ [Service] Opening settings not supported for $platformName');
      }
    } catch (e) {
      debugPrint('❌ [Service] Error opening settings: $e');
    }
  }

  /// Reinitialize the service (force refresh)
  Future<void> refresh() async {
    _isInitialized = false;
    _capability = null;
    HealthChannelFactory.resetCache();
    await initialize();
  }

  /// Clean up resources
  Future<void> dispose() async {
    if (_channel != null) {
      try {
        await _channel!.disconnect();
      } catch (e) {
        debugPrint('⚠️ [Service] Error disconnecting: $e');
      }
    }

    await HealthChannelFactory.dispose();
    _channel = null;
    _capability = null;
    _isInitialized = false;
    debugPrint('🗑️ [Service] Disposed');
  }

  /// Reset to uninitialized state
  void reset() {
    _channel = null;
    _capability = null;
    _isInitialized = false;
    HealthChannelFactory.resetCache();
    debugPrint('🔄 [Service] Reset');
  }
}
