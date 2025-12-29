import 'package:flutter/services.dart';
import '../models/health_data.dart';
import '../models/platform_capability.dart';

/// Base interface for health platform channels
abstract class HealthChannel {
  /// The method channel for this platform
  MethodChannel get channel;

  /// Platform identifier
  HealthPlatform get platform;

  /// Request permissions for health data access
  Future<bool> requestPermissions({
    List<String>? dataTypes,
  });

  /// Check if the platform is available on this device
  Future<bool> isAvailable();

  /// Check if permissions have been granted
  Future<bool> hasPermissions();

  /// Get platform capabilities and status
  Future<PlatformCapability> getCapabilities();

  /// Query steps data within a date range
  Future<List<HealthData>> querySteps({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Query distance data within a date range
  Future<List<HealthData>> queryDistance({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Query calories burned within a date range
  Future<List<HealthData>> queryCalories({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Query heart rate data within a date range
  Future<List<HealthData>> queryHeartRate({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Query multiple data types at once
  Future<Map<String, List<HealthData>>> queryMultiple({
    required List<String> dataTypes,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Subscribe to real-time health data updates
  Stream<HealthData>? subscribeToUpdates({
    required List<String> dataTypes,
  });

  /// Disconnect from the health platform
  Future<void> disconnect();
}

/// Extension methods for HealthChannel
extension HealthChannelHelpers on HealthChannel {
  /// Parse health data from JSON response
  List<HealthData> parseHealthDataList(List<dynamic>? jsonList) {
    if (jsonList == null || jsonList.isEmpty) return [];

    return jsonList
        .map((json) => HealthData.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Handle common errors from platform channels
  HealthChannelException handleError(dynamic error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'PERMISSION_DENIED':
          return HealthChannelException(
            code: error.code,
            message: 'Health permissions denied',
            type: HealthChannelErrorType.permissionDenied,
          );
        case 'NOT_AVAILABLE':
          return HealthChannelException(
            code: error.code,
            message: 'Health platform not available',
            type: HealthChannelErrorType.notAvailable,
          );
        case 'NOT_AUTHORIZED':
          return HealthChannelException(
            code: error.code,
            message: 'Not authorized to access health data',
            type: HealthChannelErrorType.notAuthorized,
          );
        case 'QUERY_FAILED':
          return HealthChannelException(
            code: error.code,
            message: error.message ?? 'Query failed',
            type: HealthChannelErrorType.queryFailed,
          );
        case 'INVALID_ARGS':
          return HealthChannelException(
            code: error.code,
            message: error.message ?? 'Invalid arguments',
            type: HealthChannelErrorType.invalidArguments,
          );
        default:
          return HealthChannelException(
            code: error.code,
            message: error.message ?? 'Unknown error',
            type: HealthChannelErrorType.unknown,
          );
      }
    }

    return HealthChannelException(
      code: 'UNKNOWN',
      message: error.toString(),
      type: HealthChannelErrorType.unknown,
    );
  }
}

/// Error types for health channel operations
enum HealthChannelErrorType {
  permissionDenied,
  notAvailable,
  notAuthorized,
  queryFailed,
  invalidArguments,
  networkError,
  timeout,
  unknown,
}

/// Exception for health channel operations
class HealthChannelException implements Exception {
  final String code;
  final String message;
  final HealthChannelErrorType type;
  final dynamic originalError;

  HealthChannelException({
    required this.code,
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'HealthChannelException($code): $message';
}
