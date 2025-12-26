import 'package:equatable/equatable.dart';

/// Leaderboard entry representing a user's position and stats
class LeaderboardEntry extends Equatable {
  /// User ID
  final String userId;

  /// User's display name
  final String displayName;

  /// User's profile photo URL
  final String? photoUrl;

  /// Current rank position (1-based)
  final int rank;

  /// Total steps for the period
  final int steps;

  /// Total distance in meters
  final double distance;

  /// Current streak (consecutive days hitting goal)
  final int streak;

  /// When this entry was last updated
  final DateTime lastUpdated;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.rank,
    required this.steps,
    required this.distance,
    required this.streak,
    required this.lastUpdated,
  });

  /// Get distance in kilometers
  double get distanceInKm => distance / 1000;

  /// Get distance in miles
  double get distanceInMiles => distance / 1609.34;

  /// Check if this is the top position
  bool get isTopRank => rank == 1;

  /// Check if this is in top 3
  bool get isTopThree => rank <= 3;

  /// Check if this is in top 10
  bool get isTopTen => rank <= 10;

  @override
  List<Object?> get props => [
        userId,
        displayName,
        photoUrl,
        rank,
        steps,
        distance,
        streak,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, name: $displayName, steps: $steps)';
  }
}
