import 'package:dartz/dartz.dart';
import '../entities/daily_summary.dart';

/// Abstract repository interface for daily health summaries
///
/// STORAGE: Firebase Firestore
/// PATH: users/{userId}/health_data/{date}
/// RESPONSIBILITY: Managing aggregated daily health data synced to cloud
///
/// This repository handles:
/// - Syncing daily summaries to Firebase
/// - Retrieving daily summaries for date ranges
/// - Real-time updates via streams
/// - Aggregation of local metrics into summaries
///
/// Using Either<DailySummaryException, T> for error handling:
/// - Left: Contains DailySummaryException with error details
/// - Right: Contains successful result data
abstract class DailySummaryRepository {
  /// Sync daily summary to Firebase
  /// This is the primary cloud storage write operation
  Future<Either<DailySummaryException, DailySummary>> syncDailySummary(
    DailySummary summary,
  );

  /// Get daily summary for a specific date from Firebase
  Future<Either<DailySummaryException, DailySummary?>> getDailySummary({
    required String userId,
    required String date,
  });

  /// Get daily summaries within a date range from Firebase
  /// Used for displaying weekly/monthly progress
  Future<Either<DailySummaryException, List<DailySummary>>> getDailySummaries({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Get today's daily summary
  Future<Either<DailySummaryException, DailySummary?>> getTodaysSummary({
    required String userId,
  });

  /// Get yesterday's daily summary
  /// Used for streak calculations
  Future<Either<DailySummaryException, DailySummary?>> getYesterdaysSummary({
    required String userId,
  });

  /// Get last N days of summaries
  Future<Either<DailySummaryException, List<DailySummary>>> getRecentSummaries({
    required String userId,
    required int days,
  });

  /// Watch daily summary changes in real-time (Stream)
  /// Used for live updates when friends achieve goals
  Stream<Either<DailySummaryException, DailySummary?>> watchDailySummary({
    required String userId,
    required String date,
  });

  /// Watch today's summary in real-time
  Stream<Either<DailySummaryException, DailySummary?>> watchTodaysSummary({
    required String userId,
  });

  /// Delete daily summary (e.g., after normalization to monthly)
  Future<Either<DailySummaryException, void>> deleteDailySummary({
    required String userId,
    required String date,
  });

  /// Delete daily summaries in a date range
  /// Used for data retention policy (60-day window)
  Future<Either<DailySummaryException, void>> deleteDailySummaries({
    required String userId,
    required String startDate,
    required String endDate,
  });

  /// Check if daily summary exists for a date
  Future<Either<DailySummaryException, bool>> hasDailySummary({
    required String userId,
    required String date,
  });
}

// ============================================================================
// EXCEPTION TYPES
// ============================================================================

/// Exception class for daily summary errors
class DailySummaryException implements Exception {
  final String message;
  final DailySummaryErrorType type;
  final dynamic originalError;

  const DailySummaryException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'DailySummaryException: $message (type: $type)';
}

/// Types of daily summary errors
enum DailySummaryErrorType {
  /// Network connectivity issues
  network,

  /// Firebase Firestore errors
  firestore,

  /// Health data not found
  dataNotFound,

  /// Invalid date format or range
  invalidDate,

  /// Sync operation failed
  syncFailed,

  /// Delete operation failed
  deleteFailed,

  /// Server error (Firebase functions)
  serverError,

  /// Unknown error
  unknown,
}
