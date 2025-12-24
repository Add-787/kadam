import 'package:equatable/equatable.dart';

/// Domain entity representing monthly aggregated health summary
///
/// STORAGE: Firebase Firestore - Synced to cloud
/// PATH: users/{userId}/health_summaries/monthly/{YYYY-MM}
///
/// PURPOSE:
/// - Normalized monthly data created from DailySummary records
/// - Part of cost optimization strategy (60-day retention window)
/// - Used for historical trends and long-term analysis
/// - Permanently retained (never deleted)
///
/// LIFECYCLE:
/// 1. After 60 days, DailySummary records for a complete month are aggregated
/// 2. Cloud Function creates MonthlySummary
/// 3. Original DailySummary records are deleted
/// 4. Reduces storage costs by ~78% over 5 years
///
/// COST OPTIMIZATION:
/// - 1 document per month (instead of 28-31 daily documents)
/// - Example: January 2025 = 31 daily docs → 1 monthly doc
class MonthlySummary extends Equatable {
  /// User ID
  final String userId;

  /// Month in YYYY-MM format
  final String month;

  /// Total steps for the month
  final int totalSteps;

  /// Average steps per day
  final int averageSteps;

  /// Best day's step count
  final int bestDaySteps;

  /// Date of the best day
  final String bestDay;

  /// Total distance in meters
  final double totalDistance;

  /// Total calories burned
  final int totalCalories;

  /// Days with activity (steps > 0)
  final int daysActive;

  /// Longest streak in this month
  final int longestStreak;

  /// Achievements unlocked this month
  final List<String> achievements;

  /// When this summary was created
  final DateTime createdAt;

  const MonthlySummary({
    required this.userId,
    required this.month,
    required this.totalSteps,
    required this.averageSteps,
    required this.bestDaySteps,
    required this.bestDay,
    required this.totalDistance,
    required this.totalCalories,
    required this.daysActive,
    this.longestStreak = 0,
    this.achievements = const [],
    required this.createdAt,
  });

  /// Get distance in kilometers
  double get distanceInKm => totalDistance / 1000;

  /// Get distance in miles
  double get distanceInMiles => totalDistance / 1609.34;

  /// Get month name (e.g., "January 2025")
  String get monthName {
    final parts = month.split('-');
    if (parts.length != 2) return month;

    final year = parts[0];
    final monthNum = int.tryParse(parts[1]) ?? 1;

    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${monthNames[monthNum - 1]} $year';
  }

  /// Get activity consistency percentage
  double get consistencyPercentage {
    // Assume 30 days in a month for simplicity
    return (daysActive / 30 * 100).clamp(0, 100);
  }

  /// Create a copy with updated fields
  MonthlySummary copyWith({
    String? userId,
    String? month,
    int? totalSteps,
    int? averageSteps,
    int? bestDaySteps,
    String? bestDay,
    double? totalDistance,
    int? totalCalories,
    int? daysActive,
    int? longestStreak,
    List<String>? achievements,
    DateTime? createdAt,
  }) {
    return MonthlySummary(
      userId: userId ?? this.userId,
      month: month ?? this.month,
      totalSteps: totalSteps ?? this.totalSteps,
      averageSteps: averageSteps ?? this.averageSteps,
      bestDaySteps: bestDaySteps ?? this.bestDaySteps,
      bestDay: bestDay ?? this.bestDay,
      totalDistance: totalDistance ?? this.totalDistance,
      totalCalories: totalCalories ?? this.totalCalories,
      daysActive: daysActive ?? this.daysActive,
      longestStreak: longestStreak ?? this.longestStreak,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        month,
        totalSteps,
        averageSteps,
        bestDaySteps,
        bestDay,
        totalDistance,
        totalCalories,
        daysActive,
        longestStreak,
        achievements,
        createdAt,
      ];

  @override
  String toString() {
    return 'MonthlySummary(month: $monthName, totalSteps: $totalSteps, avgSteps: $averageSteps, bestDay: $bestDaySteps)';
  }
}
