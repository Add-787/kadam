import 'package:flutter/services.dart';
import '../models/health_data.dart';
import '../models/platform_capability.dart';
import 'health_channel.dart';

/// Health Connect channel for Android (unified health API)
///
/// Health Connect aggregates data from multiple sources:
/// - Samsung Health
/// - Google Fit
/// - Fitbit
/// - Other health apps
///
/// Available on Android 14+ (and Android 9+ via backport)
class HealthConnectChannel implements HealthChannel {
  static const String _channelName = 'com.kadam.health/health_connect';

  @override
  final MethodChannel channel = const MethodChannel(_channelName);

  @override
  HealthPlatform get platform => HealthPlatform.healthConnect;

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'unimplemented') {
        // Not on Android or Health Connect not available
        return false;
      }
      throw handleError(e);
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final result = await channel.invokeMethod<bool>('hasPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<bool> requestPermissions({
    List<String>? dataTypes,
  }) async {
    try {
      final result = await channel.invokeMethod<bool>(
        'requestPermissions',
        {
          'dataTypes':
              dataTypes ?? ['steps', 'distance', 'calories', 'heart_rate'],
        },
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PlatformCapability> getCapabilities() async {
    try {
      final result = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'getCapabilities',
      );

      if (result == null) {
        return PlatformCapability(
          platform: platform,
          isAvailable: false,
          isAuthorized: false,
          version: '',
          supportedDataTypes: [],
        );
      }

      return PlatformCapability.fromJson(
        Map<String, dynamic>.from(result),
      );
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<HealthData>> querySteps({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await channel.invokeMethod<List<dynamic>>(
        'querySteps',
        {
          'startTime': startDate.millisecondsSinceEpoch,
          'endTime': endDate.millisecondsSinceEpoch,
        },
      );

      return parseHealthDataList(result);
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<HealthData>> queryDistance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await channel.invokeMethod<List<dynamic>>(
        'queryDistance',
        {
          'startTime': startDate.millisecondsSinceEpoch,
          'endTime': endDate.millisecondsSinceEpoch,
        },
      );

      return parseHealthDataList(result);
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<HealthData>> queryCalories({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await channel.invokeMethod<List<dynamic>>(
        'queryCalories',
        {
          'startTime': startDate.millisecondsSinceEpoch,
          'endTime': endDate.millisecondsSinceEpoch,
        },
      );

      return parseHealthDataList(result);
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<List<HealthData>> queryHeartRate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await channel.invokeMethod<List<dynamic>>(
        'queryHeartRate',
        {
          'startTime': startDate.millisecondsSinceEpoch,
          'endTime': endDate.millisecondsSinceEpoch,
        },
      );

      return parseHealthDataList(result);
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Map<String, List<HealthData>>> queryMultiple({
    required List<String> dataTypes,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'queryMultiple',
        {
          'dataTypes': dataTypes,
          'startTime': startDate.millisecondsSinceEpoch,
          'endTime': endDate.millisecondsSinceEpoch,
        },
      );

      if (result == null) return {};

      final Map<String, List<HealthData>> healthDataMap = {};

      result.forEach((key, value) {
        if (value is List) {
          healthDataMap[key.toString()] = parseHealthDataList(value);
        }
      });

      return healthDataMap;
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Stream<HealthData>? subscribeToUpdates({
    required List<String> dataTypes,
  }) {
    // Health Connect doesn't support real-time streaming by default
    // Would require EventChannel implementation
    return null;
  }

  @override
  Future<void> disconnect() async {
    try {
      await channel.invokeMethod<void>('disconnect');
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  /// Get aggregated steps for today
  Future<int> getTodaySteps() async {
    try {
      final result = await channel.invokeMethod<int>('getTodaySteps');
      return result ?? 0;
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  /// Get aggregated steps for a specific date
  Future<int> getDailySteps(DateTime date) async {
    try {
      final result = await channel.invokeMethod<int>(
        'getDailySteps',
        {
          'date': date.millisecondsSinceEpoch,
        },
      );
      return result ?? 0;
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  /// Get aggregated distance for a specific date (in meters)
  Future<double> getDailyDistance(DateTime date) async {
    try {
      final result = await channel.invokeMethod<double>(
        'getDailyDistance',
        {
          'date': date.millisecondsSinceEpoch,
        },
      );
      return result ?? 0.0;
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  /// Get aggregated calories for a specific date
  Future<int> getDailyCalories(DateTime date) async {
    try {
      final result = await channel.invokeMethod<int>(
        'getDailyCalories',
        {
          'date': date.millisecondsSinceEpoch,
        },
      );
      return result ?? 0;
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  /// Aggregate steps for a date range
  Future<Map<String, dynamic>> aggregateSteps({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'aggregateSteps',
        {
          'startTime': startDate.millisecondsSinceEpoch,
          'endTime': endDate.millisecondsSinceEpoch,
        },
      );

      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  /// Check if Health Connect app is installed
  Future<bool> isInstalled() async {
    try {
      final result = await channel.invokeMethod<bool>('isInstalled');
      return result ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'unimplemented') {
        return false;
      }
      throw handleError(e);
    }
  }

  /// Get the SDK status
  Future<String> getSdkStatus() async {
    try {
      final result = await channel.invokeMethod<String>('getSdkStatus');
      return result ?? 'unknown';
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }

  /// Open Health Connect settings
  Future<void> openSettings() async {
    try {
      await channel.invokeMethod<void>('openSettings');
    } on PlatformException catch (e) {
      throw handleError(e);
    }
  }
}
