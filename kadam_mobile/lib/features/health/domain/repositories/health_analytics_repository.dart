import 'package:dartz/dartz.dart';
import '../entities/daily_summary.dart';

/// Abstract repository interface for health analytics and statistics
///
/// RESPONSIBILITY: Computing statistics and insights from health data
///
/// This repository handles:
/// - Streak calculations
/// - Averages and totals
/// - Best day/month/year identification
/// - Goal achievement tracking
/// - Trends and insights
///
/// Data sources:
/// - DailySummary (Firebase) for recent data
/// - MonthlySummary/YearlySummary for historical data
///
/// Using Either<HealthAnalyticsException, T> for error handling:
/// - Left: Contains HealthAnalyticsException with error details
/// - Right: Contains successful result data
abstract class HealthAnalyticsRepository {
  // ============================================================================
  // STREAK ANALYTICS
  // ============================================================================

  /// Get current streak (consecutive days hitting goal)
  Future<Either<HealthAnalyticsException, int>> getCurrentStreak({
    required String userId,
  });

  /// Get longest streak ever
  Future<Either<HealthAnalyticsException, int>> getLongestStreak({
    required String userId,
  });

  /// Get streak for a specific end date
  /// Used for calculating historical streaks
  Future<Either<HealthAnalyticsException, int>> getStreakAsOf({
    required String userId,
    required String date,
  });

  /// Check if user is currently on a streak
  Future<Either<HealthAnalyticsException, bool>> isOnStreak({
    required String userId,
  });

  // ============================================================================
  // STEPS ANALYTICS
  // ============================================================================

  /// Get total steps for a date range
  Future<Either<HealthAnalyticsException, int>> getTotalSteps({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get average steps per day for a date range
  Future<Either<HealthAnalyticsException, double>> getAverageSteps({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get median steps for a date range
  Future<Either<HealthAnalyticsException, int>> getMedianSteps({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get max steps in a single day for a date range
  Future<Either<HealthAnalyticsException, int>> getMaxSteps({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get min steps in a single day for a date range
  Future<Either<HealthAnalyticsException, int>> getMinSteps({
    required String userId,
    required String startDate,
    required String endDate,
  });

  // ============================================================================
  // BEST PERFORMANCE
  // ============================================================================

  /// Get best day (highest steps) within a date range
  Future<Either<HealthAnalyticsException, DailySummary?>> getBestDay({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get best week within a date range
  Future<Either<HealthAnalyticsException, WeekStats?>> getBestWeek({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get best month ever
  Future<Either<HealthAnalyticsException, String?>> getBestMonth({
    required String userId,
  });

  // ============================================================================
  // GOAL TRACKING
  // ============================================================================

  /// Check if user achieved goal on a specific date
  Future<Either<HealthAnalyticsException, bool>> hasAchievedGoal({
    required String userId,
    required String date,
  });

  /// Get goal achievement rate (percentage of days goal was met)
  Future<Either<HealthAnalyticsException, double>> getGoalAchievementRate({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get total days goal was achieved
  Future<Either<HealthAnalyticsException, int>> getTotalGoalDays({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get consecutive goal achievement days (current)
  Future<Either<HealthAnalyticsException, int>> getConsecutiveGoalDays({
    required String userId,
  });

  // ============================================================================
  // DISTANCE ANALYTICS
  // ============================================================================

  /// Get total distance for a date range (in meters)
  Future<Either<HealthAnalyticsException, double>> getTotalDistance({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get average distance per day
  Future<Either<HealthAnalyticsException, double>> getAverageDistance({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get lifetime total distance
  Future<Either<HealthAnalyticsException, double>> getLifetimeDistance({
    required String userId,
  });

  // ============================================================================
  // TRENDS & INSIGHTS
  // ============================================================================

  /// Get trend direction (increasing, decreasing, stable)
  Future<Either<HealthAnalyticsException, TrendDirection>> getStepsTrend({
    required String userId,
    required int days,
  });

  /// Compare this week to last week
  Future<Either<HealthAnalyticsException, WeekComparison>> compareWeeks({
    required String userId,
  });

  /// Compare this month to last month
  Future<Either<HealthAnalyticsException, MonthComparison>> compareMonths({
    required String userId,
  });

  /// Get daily activity consistency score (0-100)
  /// Higher score means more consistent daily activity
  Future<Either<HealthAnalyticsException, int>> getConsistencyScore({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get most active day of week (0 = Sunday, 6 = Saturday)
  Future<Either<HealthAnalyticsException, int>> getMostActiveWeekday({
    required String userId,
  });

  /// Get least active day of week
  Future<Either<HealthAnalyticsException, int>> getLeastActiveWeekday({
    required String userId,
  });

  // ============================================================================
  // PERSONALIZED INSIGHTS
  // ============================================================================

  /// Get personalized insights for user
  /// Returns suggestions based on activity patterns
  Future<Either<HealthAnalyticsException, List<HealthInsight>>> getInsights({
    required String userId,
  });
}

// ============================================================================
// DOMAIN ENTITIES
// ============================================================================

/// Week statistics
class WeekStats {
  final String startDate;
  final String endDate;
  final int totalSteps;
  final double averageSteps;
  final int daysActive;

  const WeekStats({
    required this.startDate,
    required this.endDate,
    required this.totalSteps,
    required this.averageSteps,
    required this.daysActive,
  });
}

/// Week comparison
class WeekComparison {
  final int thisWeekSteps;
  final int lastWeekSteps;
  final int difference;
  final double percentageChange;

  const WeekComparison({
    required this.thisWeekSteps,
    required this.lastWeekSteps,
    required this.difference,
    required this.percentageChange,
  });
}

/// Month comparison
class MonthComparison {
  final int thisMonthSteps;
  final int lastMonthSteps;
  final int difference;
  final double percentageChange;

  const MonthComparison({
    required this.thisMonthSteps,
    required this.lastMonthSteps,
    required this.difference,
    required this.percentageChange,
  });
}

/// Trend direction
enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

/// Health insight
class HealthInsight {
  final String title;
  final String message;
  final InsightType type;
  final int priority;

  const HealthInsight({
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
  });
}

/// Insight types
enum InsightType {
  achievement,
  suggestion,
  warning,
  milestone,
}

// ============================================================================
// EXCEPTION TYPES
// ============================================================================

/// Exception class for health analytics errors
class HealthAnalyticsException implements Exception {
  final String message;
  final HealthAnalyticsErrorType type;
  final dynamic originalError;

  const HealthAnalyticsException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'HealthAnalyticsException: $message (type: $type)';
}

/// Types of health analytics errors
enum HealthAnalyticsErrorType {
  /// Network connectivity issues
  network,

  /// Firebase Firestore errors
  firestore,

  /// Insufficient data for calculation
  insufficientData,

  /// Invalid date format or range
  invalidDate,

  /// Calculation error
  calculationError,

  /// Unknown error
  unknown,
}
