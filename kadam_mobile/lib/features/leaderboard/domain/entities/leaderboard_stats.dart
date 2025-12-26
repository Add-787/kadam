import 'package:equatable/equatable.dart';

/// Statistics for a leaderboard
class LeaderboardStats extends Equatable {
  /// Total number of users in the leaderboard
  final int totalUsers;

  /// Average steps per user
  final int averageSteps;

  /// Median steps
  final int medianSteps;

  /// Highest step count (top performer)
  final int topSteps;

  /// When these stats were last updated
  final DateTime lastUpdated;

  const LeaderboardStats({
    required this.totalUsers,
    required this.averageSteps,
    required this.medianSteps,
    required this.topSteps,
    required this.lastUpdated,
  });

  /// Check if there are active participants
  bool get hasParticipants => totalUsers > 0;

  /// Get participation level description
  String get participationLevel {
    if (totalUsers >= 1000) return 'Highly Active';
    if (totalUsers >= 500) return 'Very Active';
    if (totalUsers >= 100) return 'Active';
    if (totalUsers >= 50) return 'Growing';
    return 'Starting';
  }

  @override
  List<Object?> get props => [
        totalUsers,
        averageSteps,
        medianSteps,
        topSteps,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'LeaderboardStats(users: $totalUsers, avg: $averageSteps, top: $topSteps)';
  }
}
