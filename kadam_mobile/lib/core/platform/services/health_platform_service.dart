import 'package:flutter/foundation.dart';
import '../channels/health_channel.dart';
import '../channels/health_connect_channel.dart';
import '../models/platform_capability.dart';

/// Service that manages the health platform channel
///
/// The health channel is injected via constructor, allowing for:
/// - Mock channel in development/testing
/// - Real platform channel (Health Connect/Apple Health) in production
/// - Easy testing with dependency injection
class HealthPlatformService {
  final HealthChannel _channel;
  bool _isInitialized = false;
  PlatformCapability? _capability;

  /// Constructor with injected health channel
  HealthPlatformService(this._channel);

  /// Get the active health channel
  HealthChannel get channel => _channel;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get the platform that was detected
  HealthPlatform get detectedPlatform => _channel.platform;

  /// Get the display name of the active platform
  String get platformName => _channel.platform.displayName;

  /// Get the platform capability information
  PlatformCapability? get capability => _capability;

  /// Initialize the service with the injected health channel
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ [Service] Already initialized with $platformName');
      return;
    }

    try {
      // Get capability information from the injected channel
      _capability = await _channel.getCapabilities();
      _isInitialized = true;

      debugPrint('✅ [Service] Initialized with $platformName');
      debugPrint('   Available: ${_capability?.isAvailable}');
      debugPrint('   Authorized: ${_capability?.isAuthorized}');
    } catch (e) {
      debugPrint('❌ [Service] Initialization error: $e');
      rethrow;
    }
  }

  /// Check if a health platform is available on this device
  bool get hasHealthPlatform => true;

  /// Check if the platform is available and functional
  Future<bool> isPlatformAvailable() async {
    try {
      return await _channel.isAvailable();
    } catch (e) {
      debugPrint('❌ [Service] Error checking availability: $e');
      return false;
    }
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    try {
      return await _channel.hasPermissions();
    } catch (e) {
      debugPrint('❌ [Service] Error checking permissions: $e');
      return false;
    }
  }

  /// Request permissions from the user
  Future<bool> requestPermissions({List<String>? dataTypes}) async {
    try {
      debugPrint('🔐 [Service] Requesting permissions for $platformName');
      debugPrint('🔐 [Service] Data types: ${dataTypes ?? "all"}');

      final granted = await _channel.requestPermissions(dataTypes: dataTypes);

      debugPrint('🔐 [Service] Permission result: $granted');

      if (granted) {
        // Update capability after granting permissions
        _capability = await _channel.getCapabilities();
        debugPrint('✅ [Service] Permissions granted');
        debugPrint(
            '   Updated authorized status: ${_capability?.isAuthorized}');
      } else {
        debugPrint('❌ [Service] Permissions denied');
      }

      return granted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] Error requesting permissions: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get platform capabilities
  Future<PlatformCapability?> getCapabilities() async {
    try {
      _capability = await _channel.getCapabilities();
      return _capability;
    } catch (e) {
      debugPrint('❌ [Service] Error getting capabilities: $e');
      return null;
    }
  }

  /// Check if the service is ready to use (initialized + has permissions)
  Future<bool> isReady() async {
    if (!_isInitialized) return false;

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
    try {
      if (_channel is HealthConnectChannel) {
        await _channel.openSettings();
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
    await initialize();
  }

  /// Clean up resources
  Future<void> dispose() async {
    try {
      await _channel.disconnect();
    } catch (e) {
      debugPrint('⚠️ [Service] Error disconnecting: $e');
    }

    _capability = null;
    _isInitialized = false;
    debugPrint('🗑️ [Service] Disposed');
  }

  /// Reset to uninitialized state
  void reset() {
    _capability = null;
    _isInitialized = false;
    debugPrint('🔄 [Service] Reset');
  }
}
