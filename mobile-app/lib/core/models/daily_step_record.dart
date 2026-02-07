import 'package:equatable/equatable.dart';

class DailyStepRecord extends Equatable {
  final String id; // format: "yyyy-MM-dd_deviceId"
  final String userId;
  final String date; // yyyy-MM-dd
  final String deviceId;
  final int stepCount;
  final int? caloriesBurned;
  final double? distanceMeters;
  final int? flightsClimbed;
  final DateTime lastUpdated;
  final Map<String, int> hourlyBreakdown;

  const DailyStepRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.deviceId,
    required this.stepCount,
    this.caloriesBurned,
    this.distanceMeters,
    this.flightsClimbed,
    required this.lastUpdated,
    this.hourlyBreakdown = const {},
  });

  factory DailyStepRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return DailyStepRecord(
      id: documentId,
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      deviceId: map['deviceId'] ?? '',
      stepCount: map['stepCount'] ?? 0,
      caloriesBurned: map['caloriesBurned'],
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble(),
      flightsClimbed: map['flightsClimbed'],
      lastUpdated: (map['lastUpdated'] as DateTime?) ?? DateTime.now(),
      hourlyBreakdown: Map<String, int>.from(map['hourlyBreakdown'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'deviceId': deviceId,
      'stepCount': stepCount,
      'caloriesBurned': caloriesBurned,
      'distanceMeters': distanceMeters,
      'flightsClimbed': flightsClimbed,
      'lastUpdated': lastUpdated,
      'hourlyBreakdown': hourlyBreakdown,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        deviceId,
        stepCount,
        caloriesBurned,
        distanceMeters,
        flightsClimbed,
        lastUpdated,
        hourlyBreakdown
      ];
}
