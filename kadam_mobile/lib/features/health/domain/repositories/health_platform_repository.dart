import 'package:dartz/dartz.dart';
import '../entities/health_metric.dart';

/// Abstract repository interface for native health platform integration
///
/// RESPONSIBILITY: Managing communication with native health platforms
///
/// This repository handles:
/// - Syncing data from Apple Health, Google Fit, Samsung Health, etc.
/// - Managing platform permissions
/// - Detecting available health sources
/// - Converting native data to HealthMetric entities
///
/// This is implemented via method channels that communicate with:
/// - iOS: HealthKit (Swift)
/// - Android: Health Connect / Google Fit (Kotlin)
/// - Android: Samsung Health SDK (Kotlin)
///
/// Using Either<HealthPlatformException, T> for error handling:
/// - Left: Contains HealthPlatformException with error details
/// - Right: Contains successful result data
abstract class HealthPlatformRepository {
  // ============================================================================
  // PLATFORM SYNC
  // ============================================================================

  /// Sync health data from native platforms (Apple Health, Google Fit, etc.)
  /// This is called by background worker to fetch latest data
  Future<Either<HealthPlatformException, List<HealthMetric>>> syncFromPlatform({
    required String userId,
    required HealthDataSource source,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Sync today's data from native platform
  /// Quick sync for real-time updates
  Future<Either<HealthPlatformException, List<HealthMetric>>>
      syncTodayFromPlatform({
    required String userId,
    required HealthDataSource source,
  });

  /// Sync data for a specific date
  Future<Either<HealthPlatformException, List<HealthMetric>>>
      syncDateFromPlatform({
    required String userId,
    required HealthDataSource source,
    required DateTime date,
  });

  /// Get step count directly from platform (without saving)
  /// Used for quick checks and real-time display
  Future<Either<HealthPlatformException, int>> getCurrentStepsFromPlatform({
    required HealthDataSource source,
  });

  /// Get last sync time for a platform
  Future<Either<HealthPlatformException, DateTime?>> getLastSyncTime({
    required String userId,
    required HealthDataSource source,
  });

  /// Update last sync time
  Future<Either<HealthPlatformException, void>> updateLastSyncTime({
    required String userId,
    required HealthDataSource source,
    required DateTime syncTime,
  });

  // ============================================================================
  // PERMISSIONS
  // ============================================================================

  /// Check if health platform permissions are granted
  Future<Either<HealthPlatformException, bool>> hasPermissions({
    required HealthDataSource source,
  });

  /// Request health platform permissions
  /// Opens native permission dialog
  Future<Either<HealthPlatformException, bool>> requestPermissions({
    required HealthDataSource source,
  });

  /// Check if specific data type permission is granted
  /// (e.g., steps, distance, heart rate)
  Future<Either<HealthPlatformException, Map<String, bool>>>
      checkDataTypePermissions({
    required HealthDataSource source,
    required List<String> dataTypes,
  });

  // ============================================================================
  // PLATFORM AVAILABILITY
  // ============================================================================

  /// Get available health data sources on this device
  Future<Either<HealthPlatformException, List<HealthDataSource>>>
      getAvailableSources();

  /// Check if a specific platform is available
  Future<Either<HealthPlatformException, bool>> isPlatformAvailable({
    required HealthDataSource source,
  });

  /// Get platform information (version, capabilities)
  Future<Either<HealthPlatformException, PlatformInfo>> getPlatformInfo({
    required HealthDataSource source,
  });

  /// Get supported data types for a platform
  /// Different platforms support different metrics
  Future<Either<HealthPlatformException, List<String>>> getSupportedDataTypes({
    required HealthDataSource source,
  });

  // ============================================================================
  // BACKGROUND SYNC CONFIGURATION
  // ============================================================================

  /// Enable background sync for a platform
  Future<Either<HealthPlatformException, void>> enableBackgroundSync({
    required HealthDataSource source,
  });

  /// Disable background sync
  Future<Either<HealthPlatformException, void>> disableBackgroundSync({
    required HealthDataSource source,
  });

  /// Check if background sync is enabled
  Future<Either<HealthPlatformException, bool>> isBackgroundSyncEnabled({
    required HealthDataSource source,
  });
}

// ============================================================================
// DOMAIN ENTITIES
// ============================================================================

/// Platform information
class PlatformInfo {
  final HealthDataSource source;
  final String platformName;
  final String? version;
  final bool isAvailable;
  final List<String> supportedDataTypes;
  final Map<String, dynamic> capabilities;

  const PlatformInfo({
    required this.source,
    required this.platformName,
    this.version,
    required this.isAvailable,
    required this.supportedDataTypes,
    this.capabilities = const {},
  });
}

// ============================================================================
// EXCEPTION TYPES
// ============================================================================

/// Exception class for health platform errors
class HealthPlatformException implements Exception {
  final String message;
  final HealthPlatformErrorType type;
  final dynamic originalError;

  const HealthPlatformException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'HealthPlatformException: $message (type: $type)';
}

/// Types of health platform errors
enum HealthPlatformErrorType {
  /// Health platform permission denied
  permissionDenied,

  /// Health platform not available on device
  platformUnavailable,

  /// Sync operation failed
  syncFailed,

  /// Invalid date range
  invalidDate,

  /// Method channel communication error
  methodChannelError,

  /// Native platform error (HealthKit, Google Fit, etc.)
  nativePlatformError,

  /// Unknown error
  unknown,
}
