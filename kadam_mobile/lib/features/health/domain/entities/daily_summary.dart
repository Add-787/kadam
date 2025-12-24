import 'package:equatable/equatable.dart';

/// Domain entity representing daily aggregated health summary
///
/// STORAGE: Firebase Firestore - Synced to cloud
/// PATH: users/{userId}/health_data/{date}
///
/// PURPOSE:
/// - Aggregated daily totals created from multiple HealthMetric records
/// - Primary cloud storage format for health data
/// - Used for leaderboards, friend comparisons, and historical analysis
/// - Synced once per day via background worker (or when daily goal is reached)
/// - Retained for 60 days before normalization to monthly/yearly summaries
///
/// DATA FLOW:
/// 1. HealthMetric records collected throughout day (local SQLite)
/// 2. Aggregated into DailySummary at end of day
/// 3. DailySummary written to Firebase (single document per day)
/// 4. Cloud Functions update leaderboards and streaks
///
/// COST OPTIMIZATION:
/// - 1 write per day per user (instead of multiple HealthMetric writes)
/// - Significantly reduces Firestore costs
class DailySummary extends Equatable {
  /// User ID
  final String userId;

  /// Date of the summary (YYYY-MM-DD)
  final String date;

  /// Total steps for the day
  final int totalSteps;

  /// Total distance in meters
  final double totalDistance;

  /// Total calories burned
  final int totalCalories;

  /// Total active minutes
  final int totalActiveMinutes;

  /// Total floors climbed
  final int totalFloors;

  /// Average heart rate for the day
  final int? averageHeartRate;

  /// Daily step goal
  final int dailyGoal;

  /// Whether the daily goal was reached
  final bool goalReached;

  /// Current streak (consecutive days with activity)
  final int currentStreak;

  /// Achievements unlocked on this day
  final List<String> achievements;

  /// When this summary was last updated
  final DateTime lastUpdated;

  const DailySummary({
    required this.userId,
    required this.date,
    required this.totalSteps,
    required this.totalDistance,
    required this.totalCalories,
    this.totalActiveMinutes = 0,
    this.totalFloors = 0,
    this.averageHeartRate,
    this.dailyGoal = 10000,
    required this.goalReached,
    this.currentStreak = 0,
    this.achievements = const [],
    required this.lastUpdated,
  });

  /// Get progress percentage towards goal
  double get progressPercentage {
    if (dailyGoal == 0) return 0;
    return (totalSteps / dailyGoal * 100).clamp(0, 100);
  }

  /// Get remaining steps to reach goal
  int get stepsRemaining {
    final remaining = dailyGoal - totalSteps;
    return remaining > 0 ? remaining : 0;
  }

  /// Get distance in kilometers
  double get distanceInKm => totalDistance / 1000;

  /// Get distance in miles
  double get distanceInMiles => totalDistance / 1609.34;

  /// Check if this is today's summary
  bool get isToday {
    final today = DateTime.now();
    final summaryDate = DateTime.parse(date);
    return summaryDate.year == today.year &&
        summaryDate.month == today.month &&
        summaryDate.day == today.day;
  }

  /// Get motivational message based on progress
  String get motivationalMessage {
    final progress = progressPercentage;
    if (goalReached) {
      return '🎉 Goal achieved! Keep it up!';
    } else if (progress >= 75) {
      return '💪 Almost there! Just ${stepsRemaining} more steps!';
    } else if (progress >= 50) {
      return '👍 Halfway there! You\'re doing great!';
    } else if (progress >= 25) {
      return '🚶 Good start! Keep moving!';
    } else {
      return '🌟 Let\'s get moving today!';
    }
  }

  /// Create a copy with updated fields
  DailySummary copyWith({
    String? userId,
    String? date,
    int? totalSteps,
    double? totalDistance,
    int? totalCalories,
    int? totalActiveMinutes,
    int? totalFloors,
    int? averageHeartRate,
    int? dailyGoal,
    bool? goalReached,
    int? currentStreak,
    List<String>? achievements,
    DateTime? lastUpdated,
  }) {
    return DailySummary(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalSteps: totalSteps ?? this.totalSteps,
      totalDistance: totalDistance ?? this.totalDistance,
      totalCalories: totalCalories ?? this.totalCalories,
      totalActiveMinutes: totalActiveMinutes ?? this.totalActiveMinutes,
      totalFloors: totalFloors ?? this.totalFloors,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      goalReached: goalReached ?? this.goalReached,
      currentStreak: currentStreak ?? this.currentStreak,
      achievements: achievements ?? this.achievements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        date,
        totalSteps,
        totalDistance,
        totalCalories,
        totalActiveMinutes,
        totalFloors,
        averageHeartRate,
        dailyGoal,
        goalReached,
        currentStreak,
        achievements,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'DailySummary(date: $date, steps: $totalSteps/$dailyGoal, streak: $currentStreak)';
  }
}
