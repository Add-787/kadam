import 'package:dartz/dartz.dart';
import '../entities/health_metric.dart';
import '../entities/daily_summary.dart';

/// Abstract repository interface for health data aggregation
///
/// RESPONSIBILITY: Aggregating raw health metrics into daily summaries
///
/// This repository handles:
/// - Converting multiple HealthMetric records into a single DailySummary
/// - Merging data from multiple sources (Apple Health + Google Fit)
/// - Calculating derived metrics (calories, active minutes)
/// - Handling data deduplication
/// - Goal tracking and streak calculations
///
/// This is typically called by:
/// - Background workers at end of day
/// - Manual sync triggers
/// - Real-time UI updates
///
/// Using Either<AggregationException, T> for error handling:
/// - Left: Contains AggregationException with error details
/// - Right: Contains successful result data
abstract class AggregationRepository {
  /// Aggregate local health metrics into daily summary
  /// This is the primary aggregation method called by background workers
  Future<Either<AggregationException, DailySummary>> aggregateToDailySummary({
    required String userId,
    required String date,
    required int dailyGoal,
  });

  /// Aggregate metrics for today
  /// Quick method for real-time UI updates
  Future<Either<AggregationException, DailySummary>> aggregateTodaysSummary({
    required String userId,
    required int dailyGoal,
  });

  /// Aggregate specific health metrics into a summary
  /// Allows manual control over which metrics to aggregate
  Future<Either<AggregationException, DailySummary>> aggregateMetrics({
    required String userId,
    required String date,
    required List<HealthMetric> metrics,
    required int dailyGoal,
  });

  /// Calculate current streak based on daily summaries
  /// Counts consecutive days where goal was achieved
  Future<Either<AggregationException, int>> calculateStreak({
    required String userId,
    required String endDate,
  });

  /// Merge data from multiple sources
  /// Handles deduplication when user has both Apple Health and Google Fit
  Future<Either<AggregationException, HealthMetric>> mergeHealthMetrics({
    required List<HealthMetric> metrics,
    required String userId,
    required String date,
  });

  /// Detect and resolve duplicate entries
  /// Returns deduplicated list of metrics
  Future<Either<AggregationException, List<HealthMetric>>> deduplicateMetrics({
    required List<HealthMetric> metrics,
  });

  /// Validate health metric data
  /// Ensures data is reasonable (e.g., not 1 million steps in a day)
  Future<Either<AggregationException, bool>> validateMetric({
    required HealthMetric metric,
  });

  /// Calculate estimated calories from steps
  /// Used when native platform doesn't provide calorie data
  Future<Either<AggregationException, int>> estimateCalories({
    required int steps,
    double? weight, // User weight in kg (optional)
    double? height, // User height in cm (optional)
  });

  /// Aggregate by time of day
  /// Returns hourly breakdown for intra-day charts
  Future<Either<AggregationException, Map<int, int>>> aggregateByHour({
    required List<HealthMetric> metrics,
  });

  /// Check if aggregation is needed for a date
  /// Returns true if there are unaggregated metrics
  Future<Either<AggregationException, bool>> needsAggregation({
    required String userId,
    required String date,
  });
}

// ============================================================================
// EXCEPTION TYPES
// ============================================================================

/// Exception class for aggregation errors
class AggregationException implements Exception {
  final String message;
  final AggregationErrorType type;
  final dynamic originalError;

  const AggregationException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'AggregationException: $message (type: $type)';
}

/// Types of aggregation errors
enum AggregationErrorType {
  /// No health metrics found to aggregate
  noDataToAggregate,

  /// Invalid date format or range
  invalidDate,

  /// Aggregation calculation failed
  calculationFailed,

  /// Data validation failed
  validationFailed,

  /// Duplicate detection failed
  deduplicationFailed,

  /// Database error during aggregation
  databaseError,

  /// Unknown error
  unknown,
}
