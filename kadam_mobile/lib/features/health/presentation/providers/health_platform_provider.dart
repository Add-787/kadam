import 'package:flutter/foundation.dart';
import '../../../../core/platform/services/health_platform_service.dart';
import '../../../../core/platform/models/platform_capability.dart';

/// Provider for managing the automatically-detected health platform
///
/// No manual selection - the platform is automatically determined based on device OS
class HealthPlatformProvider extends ChangeNotifier {
  final HealthPlatformService _platformService;

  bool _isLoading = false;
  String? _error;

  HealthPlatformProvider(this._platformService);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isInitialized => _platformService.isInitialized;
  bool get hasHealthPlatform => _platformService.hasHealthPlatform;

  HealthPlatform? get platform => _platformService.detectedPlatform;
  String get platformName => _platformService.platformName;

  PlatformCapability? get capability => _platformService.capability;

  bool get isAvailable => capability?.isAvailable ?? false;
  bool get isAuthorized => capability?.isAuthorized ?? false;
  bool get isReady => capability?.isReady ?? false;
  bool get needsPermissions => isAvailable && !isAuthorized;

  String get version => capability?.version ?? 'Unknown';
  List<String> get supportedDataTypes => capability?.supportedDataTypes ?? [];

  /// Get status message for display
  String get statusMessage {
    if (!isInitialized) return 'Not initialized';
    if (!hasHealthPlatform) return 'No health platform available';
    if (_error != null) return 'Error: $_error';
    if (!isAvailable) return '$platformName is not available';
    if (!isAuthorized) return 'Permissions required for $platformName';
    if (isReady) return '$platformName is ready';
    return 'Unknown status';
  }

  /// Get status icon
  String get statusIcon {
    if (_error != null) return '❌';
    if (!isAvailable) return '⚠️';
    if (!isAuthorized) return '🔐';
    if (isReady) return '✅';
    return '❓';
  }

  /// Initialize the health platform service
  /// Platform (mock/real) is already injected via DI
  Future<void> initialize() async {
    if (isInitialized) {
      debugPrint('✅ [Provider] Already initialized');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _platformService.initialize();

      debugPrint('✅ [Provider] Initialized with $platformName');
      debugPrint('   Available: $isAvailable');
      debugPrint('   Authorized: $isAuthorized');
      debugPrint('   Supported data types: ${supportedDataTypes.length}');
    } catch (e) {
      _error = 'Failed to initialize: $e';
      debugPrint('❌ [Provider] $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request permissions
  Future<bool> requestPermissions({List<String>? dataTypes}) async {
    if (!hasHealthPlatform) {
      _error = 'No health platform available';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final granted = await _platformService.requestPermissions(
        dataTypes: dataTypes,
      );

      if (!granted) {
        _error = 'Permissions denied by user';
      }

      return granted;
    } catch (e) {
      _error = 'Error requesting permissions: $e';
      debugPrint('❌ [Provider] $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if ready (has permissions)
  Future<bool> checkIfReady() async {
    try {
      final ready = await _platformService.isReady();
      notifyListeners();
      return ready;
    } catch (e) {
      _error = 'Error checking status: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check if a specific data type is supported
  bool supportsDataType(String dataType) {
    return _platformService.supportsDataType(dataType);
  }

  /// Refresh platform status
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _platformService.refresh();
      debugPrint('🔄 [Provider] Status refreshed');
    } catch (e) {
      _error = 'Error refreshing: $e';
      debugPrint('❌ [Provider] $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open platform settings
  Future<void> openSettings() async {
    try {
      await _platformService.openPlatformSettings();
    } catch (e) {
      _error = 'Error opening settings: $e';
      debugPrint('❌ [Provider] $_error');
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _platformService.dispose();
    super.dispose();
  }
}
