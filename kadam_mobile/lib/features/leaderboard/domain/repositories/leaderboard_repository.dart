import 'package:dartz/dartz.dart';
import '../entities/leaderboard_entry.dart';
import '../entities/leaderboard_enums.dart';
import '../entities/leaderboard_stats.dart';
import '../entities/rank_history.dart';
import '../entities/user_rank.dart';

/// Exception types for leaderboard operations
enum LeaderboardErrorType {
  /// Network or connection error
  network,

  /// User not found in leaderboard
  notFound,

  /// Permission denied (privacy settings)
  permissionDenied,

  /// User has opted out of leaderboards
  optedOut,

  /// Invalid period or parameters
  invalidParameters,

  /// Server error
  server,

  /// Unknown error
  unknown,
}

/// Exception for leaderboard operations
class LeaderboardException implements Exception {
  final String message;
  final LeaderboardErrorType type;
  final dynamic originalError;

  LeaderboardException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'LeaderboardException: $message (type: $type)';
}

/// Repository interface for leaderboard operations
abstract class LeaderboardRepository {
  // ==================== Leaderboard Retrieval ====================

  /// Get leaderboard entries for a specific period and type
  /// Returns a list of [LeaderboardEntry] or [LeaderboardException]
  Future<Either<LeaderboardException, List<LeaderboardEntry>>> getLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int? limit,
    int? offset,
  });

  /// Get user's rank in a specific leaderboard
  /// Returns [UserRank] or [LeaderboardException]
  Future<Either<LeaderboardException, UserRank>> getUserRank({
    required String userId,
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  /// Get leaderboard statistics
  /// Returns [LeaderboardStats] or [LeaderboardException]
  Future<Either<LeaderboardException, LeaderboardStats>> getLeaderboardStats({
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  // ==================== Rank History ====================

  /// Get user's rank history over time
  /// Returns list of [RankHistory] or [LeaderboardException]
  Future<Either<LeaderboardException, List<RankHistory>>> getRankHistory({
    required String userId,
    required LeaderboardType type,
    DateTime? startDate,
    DateTime? endDate,
  });

  // ==================== User Comparison ====================

  /// Compare user's stats with another user
  /// Returns a map with comparison data or [LeaderboardException]
  Future<Either<LeaderboardException, Map<String, dynamic>>> compareUsers({
    required String userId1,
    required String userId2,
    required LeaderboardPeriod period,
  });

  /// Get users near a specific rank (neighbors)
  /// Returns list of [LeaderboardEntry] or [LeaderboardException]
  Future<Either<LeaderboardException, List<LeaderboardEntry>>>
      getUsersNearRank({
    required String userId,
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int range = 5, // How many users above and below
  });

  // ==================== Opt-in/Opt-out ====================

  /// Opt user into global leaderboards
  /// Returns success or [LeaderboardException]
  Future<Either<LeaderboardException, void>> optInToGlobalLeaderboard(
    String userId,
  );

  /// Opt user out of global leaderboards
  /// Returns success or [LeaderboardException]
  Future<Either<LeaderboardException, void>> optOutOfGlobalLeaderboard(
    String userId,
  );

  /// Check if user is opted into global leaderboards
  /// Returns bool or [LeaderboardException]
  Future<Either<LeaderboardException, bool>> isOptedIntoGlobal(String userId);

  // ==================== Real-time Updates ====================

  /// Watch leaderboard changes for real-time updates
  /// Returns stream of [LeaderboardEntry] lists
  Stream<Either<LeaderboardException, List<LeaderboardEntry>>>
      watchLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int? limit,
  });

  /// Watch user's rank changes for real-time updates
  /// Returns stream of [UserRank]
  Stream<Either<LeaderboardException, UserRank>> watchUserRank({
    required String userId,
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  // ==================== Search & Filter ====================

  /// Search users in leaderboard by name
  /// Returns list of [LeaderboardEntry] or [LeaderboardException]
  Future<Either<LeaderboardException, List<LeaderboardEntry>>>
      searchLeaderboard({
    required String query,
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  // ==================== Admin/Background Operations ====================

  /// Refresh leaderboard (triggers recalculation)
  /// Typically called by background sync
  /// Returns success or [LeaderboardException]
  Future<Either<LeaderboardException, void>> refreshLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  /// Update user's leaderboard entry
  /// Typically called by background sync after daily summary update
  /// Returns success or [LeaderboardException]
  Future<Either<LeaderboardException, void>> updateUserEntry({
    required String userId,
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });
}
