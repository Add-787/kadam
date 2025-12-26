import 'package:equatable/equatable.dart';

/// User's rank information in a leaderboard
class UserRank extends Equatable {
  /// User ID
  final String userId;

  /// Current rank position
  final int rank;

  /// Total number of users in the leaderboard
  final int totalUsers;

  /// User's total steps
  final int steps;

  /// Percentile ranking (0-100)
  /// Higher is better (e.g., 90 means top 10%)
  final int percentile;

  /// When this rank was calculated
  final DateTime timestamp;

  const UserRank({
    required this.userId,
    required this.rank,
    required this.totalUsers,
    required this.steps,
    required this.percentile,
    required this.timestamp,
  });

  /// Check if user is in top 1%
  bool get isTopOnePercent => percentile >= 99;

  /// Check if user is in top 10%
  bool get isTopTenPercent => percentile >= 90;

  /// Check if user is in top half
  bool get isTopHalf => percentile >= 50;

  /// Get rank as string with suffix (1st, 2nd, 3rd, 4th, etc.)
  String get rankWithSuffix {
    if (rank % 100 >= 11 && rank % 100 <= 13) {
      return '${rank}th';
    }
    switch (rank % 10) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }

  /// Get motivational message based on rank
  String get motivationalMessage {
    if (rank == 1) return '🏆 You\'re #1! Amazing!';
    if (rank <= 3) return '🥇 Top 3! Keep it up!';
    if (rank <= 10) return '⭐ Top 10! Great work!';
    if (percentile >= 90) return '💪 Top 10%! Excellent!';
    if (percentile >= 75) return '👍 Top 25%! Well done!';
    if (percentile >= 50) return '🚶 Top half! Keep going!';
    return '🌟 Keep moving forward!';
  }

  @override
  List<Object?> get props => [
        userId,
        rank,
        totalUsers,
        steps,
        percentile,
        timestamp,
      ];

  @override
  String toString() {
    return 'UserRank(rank: $rank/$totalUsers, percentile: $percentile%)';
  }
}
