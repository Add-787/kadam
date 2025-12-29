import 'dart:io';
import 'package:flutter/material.dart';

/// Enum representing different health platforms
enum HealthPlatform {
  appleHealth,
  googleFit,
  samsungHealth,
  healthConnect,
  fitbit,
  mock,
  none,
}

/// Model representing a health platform's capabilities and status
class PlatformCapability {
  final HealthPlatform platform;
  final bool isAvailable;
  final bool isAuthorized;
  final String version;
  final List<String> supportedDataTypes;

  const PlatformCapability({
    required this.platform,
    required this.isAvailable,
    required this.isAuthorized,
    required this.version,
    required this.supportedDataTypes,
  });

  /// Create from JSON (received from native code)
  factory PlatformCapability.fromJson(Map<String, dynamic> json) {
    return PlatformCapability(
      platform: _platformFromString(json['platform'] as String),
      isAvailable: json['isAvailable'] as bool? ?? false,
      isAuthorized: json['isAuthorized'] as bool? ?? false,
      version: json['version'] as String? ?? '',
      supportedDataTypes: json['supportedDataTypes'] != null
          ? List<String>.from(json['supportedDataTypes'] as List)
          : [],
    );
  }

  /// Convert to JSON (send to native code)
  Map<String, dynamic> toJson() {
    return {
      'platform': platform.name,
      'isAvailable': isAvailable,
      'isAuthorized': isAuthorized,
      'version': version,
      'supportedDataTypes': supportedDataTypes,
    };
  }

  /// Create a copy with updated fields
  PlatformCapability copyWith({
    HealthPlatform? platform,
    bool? isAvailable,
    bool? isAuthorized,
    String? version,
    List<String>? supportedDataTypes,
  }) {
    return PlatformCapability(
      platform: platform ?? this.platform,
      isAvailable: isAvailable ?? this.isAvailable,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      version: version ?? this.version,
      supportedDataTypes: supportedDataTypes ?? this.supportedDataTypes,
    );
  }

  /// Convert string to HealthPlatform enum
  static HealthPlatform _platformFromString(String platform) {
    switch (platform.toLowerCase()) {
      case 'apple_health':
      case 'applehealth':
      case 'healthkit':
        return HealthPlatform.appleHealth;
      case 'google_fit':
      case 'googlefit':
        return HealthPlatform.googleFit;
      case 'samsung_health':
      case 'samsunghealth':
        return HealthPlatform.samsungHealth;
      case 'health_connect':
      case 'healthconnect':
        return HealthPlatform.healthConnect;
      case 'fitbit':
        return HealthPlatform.fitbit;
      default:
        return HealthPlatform.none;
    }
  }

  /// Get the platform name as a string
  String get platformName {
    switch (platform) {
      case HealthPlatform.appleHealth:
        return 'Apple Health';
      case HealthPlatform.googleFit:
        return 'Google Fit';
      case HealthPlatform.samsungHealth:
        return 'Samsung Health';
      case HealthPlatform.healthConnect:
        return 'Health Connect';
      case HealthPlatform.fitbit:
        return 'Fitbit';
      case HealthPlatform.mock:
        return 'Mock Health';
      case HealthPlatform.none:
        return 'None';
    }
  }

  /// Get the expected platform for the current device
  static HealthPlatform get currentPlatform {
    if (Platform.isIOS) {
      return HealthPlatform.appleHealth;
    } else if (Platform.isAndroid) {
      // Android 14+ should use Health Connect as primary
      // For older Android, GoogleFit is the default
      return HealthPlatform.healthConnect;
    }
    return HealthPlatform.none;
  }

  /// Check if this platform supports a specific data type
  bool supportsDataType(String dataType) {
    return supportedDataTypes.contains(dataType);
  }

  /// Check if the platform is ready to use
  bool get isReady => isAvailable && isAuthorized;

  @override
  String toString() {
    return 'PlatformCapability(platform: $platformName, available: $isAvailable, authorized: $isAuthorized, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlatformCapability &&
        other.platform == platform &&
        other.isAvailable == isAvailable &&
        other.isAuthorized == isAuthorized &&
        other.version == version;
  }

  @override
  int get hashCode {
    return platform.hashCode ^
        isAvailable.hashCode ^
        isAuthorized.hashCode ^
        version.hashCode;
  }
}

/// Extension on HealthPlatform for additional utilities
extension HealthPlatformExtension on HealthPlatform {
  /// Get the platform identifier used in method channels
  String get identifier {
    switch (this) {
      case HealthPlatform.appleHealth:
        return 'apple_health';
      case HealthPlatform.googleFit:
        return 'google_fit';
      case HealthPlatform.samsungHealth:
        return 'samsung_health';
      case HealthPlatform.healthConnect:
        return 'health_connect';
      case HealthPlatform.fitbit:
        return 'fitbit';
      case HealthPlatform.mock:
        return 'mock';
      case HealthPlatform.none:
        return 'none';
    }
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case HealthPlatform.appleHealth:
        return 'Apple Health';
      case HealthPlatform.googleFit:
        return 'Google Fit';
      case HealthPlatform.samsungHealth:
        return 'Samsung Health';
      case HealthPlatform.healthConnect:
        return 'Health Connect';
      case HealthPlatform.fitbit:
        return 'Fitbit';
      case HealthPlatform.mock:
        return 'Mock Health';
      case HealthPlatform.none:
        return 'None';
    }
  }

  /// Check if platform is native (OS-level)
  bool get isNative {
    return this == HealthPlatform.appleHealth ||
        this == HealthPlatform.googleFit ||
        this == HealthPlatform.healthConnect;
  }

  /// Check if platform requires OAuth
  bool get requiresOAuth {
    return this == HealthPlatform.fitbit;
  }

  /// Get icon for the platform
  IconData get icon {
    switch (this) {
      case HealthPlatform.appleHealth:
        return Icons.favorite;
      case HealthPlatform.googleFit:
        return Icons.fitness_center;
      case HealthPlatform.samsungHealth:
        return Icons.favorite_border;
      case HealthPlatform.healthConnect:
        return Icons.health_and_safety;
      case HealthPlatform.fitbit:
        return Icons.watch;
      case HealthPlatform.mock:
        return Icons.bug_report;
      case HealthPlatform.none:
        return Icons.not_interested;
    }
  }
}

/// Common health data types that platforms may support
class HealthDataType {
  static const String steps = 'steps';
  static const String distance = 'distance';
  static const String calories = 'calories';
  static const String heartRate = 'heart_rate';
  static const String bloodPressure = 'blood_pressure';
  static const String weight = 'weight';
  static const String height = 'height';
  static const String sleepAnalysis = 'sleep';
  static const String workouts = 'workouts';
  static const String activeEnergy = 'active_energy';
  static const String restingHeartRate = 'resting_heart_rate';
  static const String vo2Max = 'vo2_max';
  static const String bloodGlucose = 'blood_glucose';
  static const String bodyTemperature = 'body_temperature';
  static const String oxygenSaturation = 'oxygen_saturation';

  /// Get all standard data types
  static List<String> get all => [
        steps,
        distance,
        calories,
        heartRate,
        bloodPressure,
        weight,
        height,
        sleepAnalysis,
        workouts,
        activeEnergy,
        restingHeartRate,
        vo2Max,
        bloodGlucose,
        bodyTemperature,
        oxygenSaturation,
      ];

  /// Get essential data types for step tracking app
  static List<String> get essential => [
        steps,
        distance,
        calories,
        heartRate,
      ];
}
