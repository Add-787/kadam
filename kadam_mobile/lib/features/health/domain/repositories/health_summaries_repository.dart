import 'package:dartz/dartz.dart';
import '../entities/monthly_summary.dart';
import '../entities/yearly_summary.dart';

/// Abstract repository interface for long-term health summaries
///
/// STORAGE: Firebase Firestore
/// PATH: users/{userId}/health_summaries/monthly/{YYYY-MM}
///       users/{userId}/health_summaries/yearly/{YYYY}
/// RESPONSIBILITY: Managing normalized historical health data
///
/// This repository handles:
/// - Monthly summaries (created after 60-day retention window)
/// - Yearly summaries (created at year end)
/// - Historical trend analysis
/// - Cost-optimized storage
///
/// Using Either<HealthSummariesException, T> for error handling:
/// - Left: Contains HealthSummariesException with error details
/// - Right: Contains successful result data
abstract class HealthSummariesRepository {
  // ============================================================================
  // MONTHLY SUMMARIES
  // ============================================================================

  /// Get monthly summary for a specific month from Firebase
  Future<Either<HealthSummariesException, MonthlySummary?>> getMonthlySummary({
    required String userId,
    required String month, // Format: YYYY-MM
  });

  /// Get monthly summaries within a date range
  Future<Either<HealthSummariesException, List<MonthlySummary>>>
      getMonthlySummaries({
    required String userId,
    required String startMonth,
    required String endMonth,
  });

  /// Get all monthly summaries for a user
  /// Used for historical trends
  Future<Either<HealthSummariesException, List<MonthlySummary>>>
      getAllMonthlySummaries({
    required String userId,
  });

  /// Save monthly summary to Firebase
  /// Typically called by Cloud Function during normalization
  Future<Either<HealthSummariesException, MonthlySummary>> saveMonthlySummary(
    MonthlySummary summary,
  );

  /// Delete monthly summary
  Future<Either<HealthSummariesException, void>> deleteMonthlySummary({
    required String userId,
    required String month,
  });

  /// Check if monthly summary exists
  Future<Either<HealthSummariesException, bool>> hasMonthlySummary({
    required String userId,
    required String month,
  });

  // ============================================================================
  // YEARLY SUMMARIES
  // ============================================================================

  /// Get yearly summary for a specific year from Firebase
  Future<Either<HealthSummariesException, YearlySummary?>> getYearlySummary({
    required String userId,
    required String year, // Format: YYYY
  });

  /// Get all yearly summaries for a user
  /// Used for lifetime stats and achievements
  Future<Either<HealthSummariesException, List<YearlySummary>>>
      getAllYearlySummaries({
    required String userId,
  });

  /// Get yearly summaries within a range
  Future<Either<HealthSummariesException, List<YearlySummary>>>
      getYearlySummaries({
    required String userId,
    required String startYear,
    required String endYear,
  });

  /// Save yearly summary to Firebase
  /// Typically called by Cloud Function at year end
  Future<Either<HealthSummariesException, YearlySummary>> saveYearlySummary(
    YearlySummary summary,
  );

  /// Delete yearly summary
  Future<Either<HealthSummariesException, void>> deleteYearlySummary({
    required String userId,
    required String year,
  });

  /// Check if yearly summary exists
  Future<Either<HealthSummariesException, bool>> hasYearlySummary({
    required String userId,
    required String year,
  });

  // ============================================================================
  // LIFETIME STATISTICS
  // ============================================================================

  /// Get lifetime total steps across all yearly summaries
  Future<Either<HealthSummariesException, int>> getLifetimeSteps({
    required String userId,
  });

  /// Get lifetime total distance
  Future<Either<HealthSummariesException, double>> getLifetimeDistance({
    required String userId,
  });

  /// Get best year ever
  Future<Either<HealthSummariesException, YearlySummary?>> getBestYear({
    required String userId,
  });

  /// Get best month ever
  Future<Either<HealthSummariesException, MonthlySummary?>> getBestMonth({
    required String userId,
  });
}

// ============================================================================
// EXCEPTION TYPES
// ============================================================================

/// Exception class for health summaries errors
class HealthSummariesException implements Exception {
  final String message;
  final HealthSummariesErrorType type;
  final dynamic originalError;

  const HealthSummariesException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'HealthSummariesException: $message (type: $type)';
}

/// Types of health summaries errors
enum HealthSummariesErrorType {
  /// Network connectivity issues
  network,

  /// Firebase Firestore errors
  firestore,

  /// Health data not found
  dataNotFound,

  /// Invalid date format or range
  invalidDate,

  /// Save operation failed
  saveFailed,

  /// Delete operation failed
  deleteFailed,

  /// Server error (Firebase functions)
  serverError,

  /// Unknown error
  unknown,
}
