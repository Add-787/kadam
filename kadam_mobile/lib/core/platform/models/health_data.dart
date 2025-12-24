import 'platform_capability.dart';

/// Model representing a single health data point
class HealthData {
  final String id;
  final HealthPlatform source;
  final String dataType;
  final dynamic value;
  final String unit;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic>? metadata;

  const HealthData({
    required this.id,
    required this.source,
    required this.dataType,
    required this.value,
    required this.unit,
    required this.startTime,
    required this.endTime,
    this.metadata,
  });

  /// Create from JSON
  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'] as String,
      source: _parseHealthPlatform(json['source'] as String),
      dataType: json['dataType'] as String,
      value: json['value'],
      unit: json['unit'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source.identifier,
      'dataType': dataType,
      'value': value,
      'unit': unit,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  HealthData copyWith({
    String? id,
    HealthPlatform? source,
    String? dataType,
    dynamic value,
    String? unit,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? metadata,
  }) {
    return HealthData(
      id: id ?? this.id,
      source: source ?? this.source,
      dataType: dataType ?? this.dataType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get numeric value (handles int, double, String conversion)
  double get numericValue {
    if (value is num) {
      return (value as num).toDouble();
    } else if (value is String) {
      return double.tryParse(value as String) ?? 0.0;
    }
    return 0.0;
  }

  /// Get duration of the data point
  Duration get duration => endTime.difference(startTime);

  /// Check if data is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dataDay = DateTime(startTime.year, startTime.month, startTime.day);
    return dataDay.isAtSameMomentAs(today);
  }

  static HealthPlatform _parseHealthPlatform(String source) {
    switch (source.toLowerCase()) {
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

  @override
  String toString() {
    return 'HealthData(type: $dataType, value: $value $unit, source: ${source.displayName}, time: $startTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthData &&
        other.id == id &&
        other.source == source &&
        other.dataType == dataType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ source.hashCode ^ dataType.hashCode;
  }
}

/// Aggregated health metrics for a specific time period
class HealthMetrics {
  final DateTime date;
  final int steps;
  final double distance; // in meters
  final double calories; // in kcal
  final int? heartRate; // average BPM
  final int? activeMinutes;
  final Map<HealthPlatform, int>? stepsBySource;

  const HealthMetrics({
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
    this.heartRate,
    this.activeMinutes,
    this.stepsBySource,
  });

  /// Create from JSON
  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    Map<HealthPlatform, int>? stepsBySource;
    if (json['stepsBySource'] != null) {
      final Map<String, dynamic> sourcesMap =
          Map<String, dynamic>.from(json['stepsBySource'] as Map);
      stepsBySource = sourcesMap.map((key, value) {
        final platform = _parsePlatform(key);
        return MapEntry(platform, value as int);
      });
    }

    return HealthMetrics(
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int,
      distance: (json['distance'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      heartRate: json['heartRate'] as int?,
      activeMinutes: json['activeMinutes'] as int?,
      stepsBySource: stepsBySource,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'steps': steps,
      'distance': distance,
      'calories': calories,
      if (heartRate != null) 'heartRate': heartRate,
      if (activeMinutes != null) 'activeMinutes': activeMinutes,
      if (stepsBySource != null)
        'stepsBySource': stepsBySource!.map(
          (key, value) => MapEntry(key.identifier, value),
        ),
    };
  }

  /// Create empty metrics
  factory HealthMetrics.empty(DateTime date) {
    return HealthMetrics(
      date: date,
      steps: 0,
      distance: 0.0,
      calories: 0.0,
    );
  }

  /// Get distance in kilometers
  double get distanceInKm => distance / 1000;

  /// Get distance in miles
  double get distanceInMiles => distance / 1609.34;

  /// Check if daily goal is met (assuming 10,000 steps)
  bool get isGoalMet => steps >= 10000;

  /// Get goal completion percentage
  double getGoalPercentage([int goal = 10000]) {
    return (steps / goal * 100).clamp(0, 100);
  }

  /// Merge metrics from multiple sources (take highest values)
  HealthMetrics merge(HealthMetrics other) {
    return HealthMetrics(
      date: date,
      steps: steps > other.steps ? steps : other.steps,
      distance: distance > other.distance ? distance : other.distance,
      calories: calories > other.calories ? calories : other.calories,
      heartRate: heartRate ?? other.heartRate,
      activeMinutes: activeMinutes ?? other.activeMinutes,
      stepsBySource: {
        ...?stepsBySource,
        ...?other.stepsBySource,
      },
    );
  }

  /// Create a copy with updated fields
  HealthMetrics copyWith({
    DateTime? date,
    int? steps,
    double? distance,
    double? calories,
    int? heartRate,
    int? activeMinutes,
    Map<HealthPlatform, int>? stepsBySource,
  }) {
    return HealthMetrics(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      heartRate: heartRate ?? this.heartRate,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      stepsBySource: stepsBySource ?? this.stepsBySource,
    );
  }

  static HealthPlatform _parsePlatform(String source) {
    switch (source.toLowerCase()) {
      case 'apple_health':
      case 'applehealth':
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

  @override
  String toString() {
    return 'HealthMetrics(date: ${date.toIso8601String().split('T')[0]}, steps: $steps, distance: ${distanceInKm.toStringAsFixed(2)}km, calories: ${calories.toStringAsFixed(0)}kcal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthMetrics &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day &&
        other.steps == steps;
  }

  @override
  int get hashCode {
    return date.hashCode ^ steps.hashCode;
  }
}
