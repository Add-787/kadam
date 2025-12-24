import 'package:dartz/dartz.dart';
import '../entities/health_metric.dart';

/// Abstract repository interface for local health metrics operations
///
/// STORAGE: Local SQLite database only
/// RESPONSIBILITY: Managing raw health data points collected throughout the day
///
/// This repository handles:
/// - Saving health metrics from native platforms
/// - Retrieving metrics for real-time UI updates
/// - Cleaning up old aggregated metrics
/// - Managing local database lifecycle
///
/// Using Either<HealthMetricsException, T> for error handling:
/// - Left: Contains HealthMetricsException with error details
/// - Right: Contains successful result data
abstract class HealthMetricsRepository {
  /// Save a health metric to local database
  /// Returns the saved metric on success
  Future<Either<HealthMetricsException, HealthMetric>> saveHealthMetric(
    HealthMetric metric,
  );

  /// Save multiple health metrics in a batch
  /// More efficient for syncing large amounts of data from native platforms
  Future<Either<HealthMetricsException, List<HealthMetric>>> saveHealthMetrics(
    List<HealthMetric> metrics,
  );

  /// Get all health metrics for a specific date (local SQLite)
  /// Used for real-time UI updates and intra-day charts
  Future<Either<HealthMetricsException, List<HealthMetric>>> getHealthMetrics({
    required String userId,
    required String date,
  });

  /// Get health metrics within a date range (local SQLite)
  /// Used for weekly/monthly charts
  Future<Either<HealthMetricsException, List<HealthMetric>>>
      getHealthMetricsRange({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get the latest health metric for today
  /// Used for displaying current step count
  Future<Either<HealthMetricsException, HealthMetric?>> getLatestHealthMetric({
    required String userId,
  });

  /// Get metrics by source (e.g., only Apple Health data)
  Future<Either<HealthMetricsException, List<HealthMetric>>>
      getHealthMetricsBySource({
    required String userId,
    required String date,
    required HealthDataSource source,
  });

  /// Mark health metrics as aggregated (after DailySummary sync)
  /// This allows old metrics to be safely deleted
  Future<Either<HealthMetricsException, void>> markHealthMetricsAsAggregated(
    List<String> metricIds,
  );

  /// Delete old health metrics from local database
  /// Typically called after aggregation, keeps last 7 days
  Future<Either<HealthMetricsException, void>> deleteOldHealthMetrics({
    required int daysToKeep,
  });

  /// Get count of unaggregated metrics
  /// Used to determine if background sync is needed
  Future<Either<HealthMetricsException, int>> getUnaggregatedCount({
    required String userId,
  });

  /// Delete all health metrics for a user (e.g., account deletion)
  Future<Either<HealthMetricsException, void>> deleteAllHealthMetrics({
    required String userId,
  });
}

// ============================================================================
// EXCEPTION TYPES
// ============================================================================

/// Exception class for health metrics errors
class HealthMetricsException implements Exception {
  final String message;
  final HealthMetricsErrorType type;
  final dynamic originalError;

  const HealthMetricsException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'HealthMetricsException: $message (type: $type)';
}

/// Types of health metrics errors
enum HealthMetricsErrorType {
  /// Local database errors (SQLite)
  database,

  /// Health data not found
  dataNotFound,

  /// Invalid date format or range
  invalidDate,

  /// Save operation failed
  saveFailed,

  /// Delete operation failed
  deleteFailed,

  /// Unknown error
  unknown,
}
