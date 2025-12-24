import 'package:dartz/dartz.dart';
import '../entities/health_metric.dart';
import '../entities/daily_summary.dart';
import '../entities/monthly_summary.dart';
import '../entities/yearly_summary.dart';

/// Abstract repository interface for health data operations
///
/// This repository follows the Repository Pattern from Clean Architecture.
/// The data layer will provide concrete implementations (e.g., HealthRepositoryImpl)
/// that can interact with different data sources:
/// - Local SQLite database for HealthMetric records
/// - Firebase Firestore for DailySummary, MonthlySummary, YearlySummary
/// - Native health platforms via method channels
///
/// Using Either<HealthException, T> for error handling:
/// - Left: Contains HealthException with error details
/// - Right: Contains successful result data
/// DEPRECATED: This repository has been split into smaller, focused repositories
///
/// Please use the following repositories instead:
///
/// 1. HealthMetricsRepository - Local SQLite operations for raw health data points
///    - saveHealthMetric()
///    - getHealthMetrics()
///    - deleteOldHealthMetrics()
///
/// 2. DailySummaryRepository - Firebase operations for daily aggregated data
///    - syncDailySummary()
///    - getDailySummary()
///    - watchDailySummary()
///
/// 3. HealthSummariesRepository - Firebase operations for monthly/yearly summaries
///    - getMonthlySummary()
///    - getYearlySummary()
///    - getLifetimeSteps()
///
/// 4. HealthPlatformRepository - Native platform integration (Apple Health, Google Fit)
///    - syncFromPlatform()
///    - hasPermissions()
///    - requestPermissions()
///
/// 5. HealthAnalyticsRepository - Statistics and insights
///    - getCurrentStreak()
///    - getTotalSteps()
///    - getBestDay()
///    - getInsights()
///
/// 6. HealthAggregationRepository - Aggregation logic
///    - aggregateToDailySummary()
///    - calculateStreak()
///    - mergeHealthMetrics()
///
/// This repository will be removed in a future version.
@Deprecated('Use specialized health repositories instead')
abstract class HealthRepository {
  // ============================================================================
  // LOCAL HEALTH METRICS (SQLite)
  // ============================================================================

  /// Save a health metric to local database
  /// Returns the saved metric on success
  Future<Either<HealthException, HealthMetric>> saveHealthMetric(
    HealthMetric metric,
  );

  /// Get all health metrics for a specific date (local SQLite)
  /// Used for real-time UI updates and intra-day charts
  Future<Either<HealthException, List<HealthMetric>>> getHealthMetrics({
    required String userId,
    required String date,
  });

  /// Get health metrics within a date range (local SQLite)
  /// Used for weekly/monthly charts
  Future<Either<HealthException, List<HealthMetric>>> getHealthMetricsRange({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get the latest health metric for today
  /// Used for displaying current step count
  Future<Either<HealthException, HealthMetric?>> getLatestHealthMetric({
    required String userId,
  });

  /// Mark health metrics as aggregated (after DailySummary sync)
  /// This allows old metrics to be safely deleted
  Future<Either<HealthException, void>> markHealthMetricsAsAggregated(
    List<String> metricIds,
  );

  /// Delete old health metrics from local database
  /// Typically called after aggregation, keeps last 7 days
  Future<Either<HealthException, void>> deleteOldHealthMetrics({
    required int daysToKeep,
  });

  // ============================================================================
  // DAILY SUMMARIES (Firebase Firestore)
  // ============================================================================

  /// Sync daily summary to Firebase
  /// This is the primary cloud storage write operation
  Future<Either<HealthException, DailySummary>> syncDailySummary(
    DailySummary summary,
  );

  /// Get daily summary for a specific date from Firebase
  Future<Either<HealthException, DailySummary?>> getDailySummary({
    required String userId,
    required String date,
  });

  /// Get daily summaries within a date range from Firebase
  /// Used for displaying weekly/monthly progress
  Future<Either<HealthException, List<DailySummary>>> getDailySummaries({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get today's daily summary
  Future<Either<HealthException, DailySummary?>> getTodaysSummary({
    required String userId,
  });

  /// Watch daily summary changes in real-time (Stream)
  /// Used for live updates when friends achieve goals
  Stream<Either<HealthException, DailySummary?>> watchDailySummary({
    required String userId,
    required String date,
  });

  /// Aggregate local health metrics into daily summary
  /// This is typically called at end of day by background worker
  Future<Either<HealthException, DailySummary>> aggregateToDailySummary({
    required String userId,
    required String date,
    required int dailyGoal,
  });

  // ============================================================================
  // MONTHLY SUMMARIES (Firebase Firestore)
  // ============================================================================

  /// Get monthly summary for a specific month from Firebase
  Future<Either<HealthException, MonthlySummary?>> getMonthlySummary({
    required String userId,
    required String month, // Format: YYYY-MM
  });

  /// Get monthly summaries within a date range
  Future<Either<HealthException, List<MonthlySummary>>> getMonthlySummaries({
    required String userId,
    required String startMonth,
    required String endMonth,
  });

  /// Get all monthly summaries for a user
  /// Used for historical trends
  Future<Either<HealthException, List<MonthlySummary>>> getAllMonthlySummaries({
    required String userId,
  });

  // ============================================================================
  // YEARLY SUMMARIES (Firebase Firestore)
  // ============================================================================

  /// Get yearly summary for a specific year from Firebase
  Future<Either<HealthException, YearlySummary?>> getYearlySummary({
    required String userId,
    required String year, // Format: YYYY
  });

  /// Get all yearly summaries for a user
  /// Used for lifetime stats and achievements
  Future<Either<HealthException, List<YearlySummary>>> getAllYearlySummaries({
    required String userId,
  });

  // ============================================================================
  // NATIVE HEALTH PLATFORM SYNC
  // ============================================================================

  /// Sync health data from native platforms (Apple Health, Google Fit, etc.)
  /// This is called by background worker to fetch latest data
  Future<Either<HealthException, List<HealthMetric>>> syncFromNativePlatform({
    required String userId,
    required HealthDataSource source,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Check if health platform permissions are granted
  Future<Either<HealthException, bool>> hasHealthPermissions({
    required HealthDataSource source,
  });

  /// Request health platform permissions
  Future<Either<HealthException, bool>> requestHealthPermissions({
    required HealthDataSource source,
  });

  /// Get available health data sources on this device
  Future<Either<HealthException, List<HealthDataSource>>> getAvailableSources();

  // ============================================================================
  // STATISTICS & ANALYTICS
  // ============================================================================

  /// Get current streak (consecutive days hitting goal)
  Future<Either<HealthException, int>> getCurrentStreak({
    required String userId,
  });

  /// Get total steps for a date range
  Future<Either<HealthException, int>> getTotalSteps({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get average steps per day for a date range
  Future<Either<HealthException, double>> getAverageSteps({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get best day (highest steps) within a date range
  Future<Either<HealthException, DailySummary?>> getBestDay({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Check if user achieved goal on a specific date
  Future<Either<HealthException, bool>> hasAchievedGoal({
    required String userId,
    required String date,
  });
}

// ============================================================================
// EXCEPTION TYPES
// ============================================================================

/// Exception class for health-related errors
class HealthException implements Exception {
  final String message;
  final HealthErrorType type;
  final dynamic originalError;

  const HealthException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'HealthException: $message (type: $type)';
}

/// Types of health errors
enum HealthErrorType {
  /// Network connectivity issues
  network,

  /// Local database errors (SQLite)
  database,

  /// Firebase Firestore errors
  firestore,

  /// Health platform permission denied
  permissionDenied,

  /// Health platform not available on device
  platformUnavailable,

  /// Health data not found
  dataNotFound,

  /// Invalid date format or range
  invalidDate,

  /// Sync operation failed
  syncFailed,

  /// Aggregation operation failed
  aggregationFailed,

  /// Server error (Firebase functions)
  serverError,

  /// Unknown error
  unknown,
}
