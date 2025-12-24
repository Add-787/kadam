import 'package:equatable/equatable.dart';

/// Domain entity representing a single health metric data point
///
/// STORAGE: Local SQLite database only - NOT synced to Firebase
///
/// PURPOSE:
/// - Stores raw data points collected throughout the day from health platforms
/// - Used for real-time step tracking and intra-day charts/graphs
/// - Multiple records per day (e.g., hourly updates from Apple Health)
/// - Aggregated locally into DailySummary for Firebase sync
/// - Can be deleted after aggregation (typically keep last 7 days)
///
/// LIFECYCLE:
/// 1. Collected from native platforms via method channels
/// 2. Stored in local SQLite for fast access
/// 3. Aggregated into DailySummary at end of day
/// 4. Marked as aggregated and eventually deleted
class HealthMetric extends Equatable {
  /// Unique identifier for this health data entry
  final String id;

  /// User ID this health data belongs to
  final String userId;

  /// Date of the health data (YYYY-MM-DD format)
  final String date;

  /// Total steps taken
  final int steps;

  /// Distance covered in meters
  final double distance;

  /// Calories burned
  final int calories;

  /// Active minutes
  final int activeMinutes;

  /// Floors climbed
  final int floors;

  /// Heart rate (average for the day)
  final int? heartRate;

  /// Source of the health data
  final HealthDataSource source;

  /// Steps breakdown by source (for multiple sources)
  final Map<String, int> stepsBySource;

  /// When this data was last synced
  final DateTime lastSyncTime;

  /// Timestamp when this record was created
  final DateTime timestamp;

  /// Whether this data has been aggregated into DailySummary
  /// (Used to determine if this local record can be safely deleted)
  final bool synced;

  const HealthMetric({
    required this.id,
    required this.userId,
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
    this.activeMinutes = 0,
    this.floors = 0,
    this.heartRate,
    required this.source,
    this.stepsBySource = const {},
    required this.lastSyncTime,
    required this.timestamp,
    this.synced = false,
  });

  /// Check if user has reached a specific step goal
  bool hasReachedGoal(int goal) => steps >= goal;

  /// Get distance in kilometers
  double get distanceInKm => distance / 1000;

  /// Get distance in miles
  double get distanceInMiles => distance / 1609.34;

  /// Calculate estimated calories if not provided
  int get estimatedCalories {
    if (calories > 0) return calories;
    // Rough estimate: 0.04 calories per step
    return (steps * 0.04).round();
  }

  /// Check if this is today's data
  bool get isToday {
    final today = DateTime.now();
    final dataDate = DateTime.parse(date);
    return dataDate.year == today.year &&
        dataDate.month == today.month &&
        dataDate.day == today.day;
  }

  /// Get source display name
  String get sourceDisplayName {
    switch (source) {
      case HealthDataSource.appleHealth:
        return 'Apple Health';
      case HealthDataSource.googleFit:
        return 'Google Fit';
      case HealthDataSource.samsungHealth:
        return 'Samsung Health';
      case HealthDataSource.fitbit:
        return 'Fitbit';
      case HealthDataSource.healthConnect:
        return 'Health Connect';
      case HealthDataSource.manual:
        return 'Manual Entry';
      case HealthDataSource.unknown:
        return 'Unknown';
    }
  }

  /// Create a copy with updated fields
  HealthMetric copyWith({
    String? id,
    String? userId,
    String? date,
    int? steps,
    double? distance,
    int? calories,
    int? activeMinutes,
    int? floors,
    int? heartRate,
    HealthDataSource? source,
    Map<String, int>? stepsBySource,
    DateTime? lastSyncTime,
    DateTime? timestamp,
    bool? synced,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      floors: floors ?? this.floors,
      heartRate: heartRate ?? this.heartRate,
      source: source ?? this.source,
      stepsBySource: stepsBySource ?? this.stepsBySource,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        steps,
        distance,
        calories,
        activeMinutes,
        floors,
        heartRate,
        source,
        stepsBySource,
        lastSyncTime,
        timestamp,
        synced,
      ];

  @override
  String toString() {
    return 'HealthMetric(date: $date, steps: $steps, distance: ${distanceInKm.toStringAsFixed(2)}km, source: $sourceDisplayName)';
  }
}

/// Source of health data
enum HealthDataSource {
  appleHealth,
  googleFit,
  samsungHealth,
  fitbit,
  healthConnect,
  manual,
  unknown,
}

/// Extension to convert string to HealthDataSource
extension HealthDataSourceExtension on String {
  HealthDataSource toHealthDataSource() {
    switch (toLowerCase()) {
      case 'apple_health':
      case 'applehealth':
        return HealthDataSource.appleHealth;
      case 'google_fit':
      case 'googlefit':
        return HealthDataSource.googleFit;
      case 'samsung_health':
      case 'samsunghealth':
        return HealthDataSource.samsungHealth;
      case 'fitbit':
        return HealthDataSource.fitbit;
      case 'health_connect':
      case 'healthconnect':
        return HealthDataSource.healthConnect;
      case 'manual':
        return HealthDataSource.manual;
      default:
        return HealthDataSource.unknown;
    }
  }
}

extension HealthDataSourceStringExtension on HealthDataSource {
  String toShortString() {
    return toString().split('.').last;
  }
}
