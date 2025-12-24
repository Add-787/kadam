import 'package:equatable/equatable.dart';

/// Domain entity representing yearly aggregated health summary
///
/// STORAGE: Firebase Firestore - Synced to cloud
/// PATH: users/{userId}/health_summaries/yearly/{YYYY}
///
/// PURPOSE:
/// - Normalized yearly data created from MonthlySummary records
/// - Part of cost optimization strategy
/// - Used for year-over-year comparisons and lifetime stats
/// - Permanently retained (never deleted)
///
/// LIFECYCLE:
/// 1. After a year is complete, MonthlySummary records are aggregated
/// 2. Cloud Function creates YearlySummary
/// 3. MonthlySummary records can optionally be kept for detail
/// 4. Provides high-level overview for user's fitness journey
///
/// COST OPTIMIZATION:
/// - 1 document per year (instead of 12 monthly documents)
/// - Example: 2025 = 12 monthly docs → 1 yearly doc (optional compression)
/// - Perfect for "lifetime stats" and achievements
class YearlySummary extends Equatable {
  /// User ID
  final String userId;

  /// Year (YYYY)
  final String year;

  /// Total steps for the year
  final int totalSteps;

  /// Average steps per day
  final int averageSteps;

  /// Best month's total steps
  final int bestMonthSteps;

  /// Name of the best month
  final String bestMonth;

  /// Best single day's step count
  final int bestDaySteps;

  /// Date of the best day
  final String bestDay;

  /// Total distance in meters
  final double totalDistance;

  /// Total calories burned
  final int totalCalories;

  /// Days with activity (steps > 0)
  final int daysActive;

  /// Longest streak in the year
  final int longestStreak;

  /// Top achievements unlocked this year
  final List<String> topAchievements;

  /// When this summary was created
  final DateTime createdAt;

  const YearlySummary({
    required this.userId,
    required this.year,
    required this.totalSteps,
    required this.averageSteps,
    required this.bestMonthSteps,
    required this.bestMonth,
    required this.bestDaySteps,
    required this.bestDay,
    required this.totalDistance,
    required this.totalCalories,
    required this.daysActive,
    this.longestStreak = 0,
    this.topAchievements = const [],
    required this.createdAt,
  });

  /// Get distance in kilometers
  double get distanceInKm => totalDistance / 1000;

  /// Get distance in miles
  double get distanceInMiles => totalDistance / 1609.34;

  /// Get activity consistency percentage (out of 365 days)
  double get consistencyPercentage {
    return (daysActive / 365 * 100).clamp(0, 100);
  }

  /// Estimate equivalent distances
  String get equivalentDistance {
    final km = distanceInKm;
    if (km > 40075) {
      // Circumference of Earth
      final times = (km / 40075).toStringAsFixed(2);
      return '$times times around Earth 🌍';
    } else if (km > 3474) {
      // Distance to moon
      final percent = (km / 384400 * 100).toStringAsFixed(1);
      return '$percent% to the Moon 🌙';
    } else if (km > 100) {
      return '${km.toStringAsFixed(0)} km total';
    } else {
      return '${distanceInMiles.toStringAsFixed(0)} miles total';
    }
  }

  /// Create a copy with updated fields
  YearlySummary copyWith({
    String? userId,
    String? year,
    int? totalSteps,
    int? averageSteps,
    int? bestMonthSteps,
    String? bestMonth,
    int? bestDaySteps,
    String? bestDay,
    double? totalDistance,
    int? totalCalories,
    int? daysActive,
    int? longestStreak,
    List<String>? topAchievements,
    DateTime? createdAt,
  }) {
    return YearlySummary(
      userId: userId ?? this.userId,
      year: year ?? this.year,
      totalSteps: totalSteps ?? this.totalSteps,
      averageSteps: averageSteps ?? this.averageSteps,
      bestMonthSteps: bestMonthSteps ?? this.bestMonthSteps,
      bestMonth: bestMonth ?? this.bestMonth,
      bestDaySteps: bestDaySteps ?? this.bestDaySteps,
      bestDay: bestDay ?? this.bestDay,
      totalDistance: totalDistance ?? this.totalDistance,
      totalCalories: totalCalories ?? this.totalCalories,
      daysActive: daysActive ?? this.daysActive,
      longestStreak: longestStreak ?? this.longestStreak,
      topAchievements: topAchievements ?? this.topAchievements,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        year,
        totalSteps,
        averageSteps,
        bestMonthSteps,
        bestMonth,
        bestDaySteps,
        bestDay,
        totalDistance,
        totalCalories,
        daysActive,
        longestStreak,
        topAchievements,
        createdAt,
      ];

  @override
  String toString() {
    return 'YearlySummary(year: $year, totalSteps: $totalSteps, avgSteps: $averageSteps, longestStreak: $longestStreak)';
  }
}
