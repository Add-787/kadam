/// Leaderboard time periods
enum LeaderboardPeriod {
  /// Today's leaderboard
  daily,

  /// This week's leaderboard
  weekly,

  /// All-time leaderboard
  allTime;

  /// Get display name
  String get displayName {
    switch (this) {
      case LeaderboardPeriod.daily:
        return 'Daily';
      case LeaderboardPeriod.weekly:
        return 'Weekly';
      case LeaderboardPeriod.allTime:
        return 'All Time';
    }
  }

  /// Get description
  String get description {
    switch (this) {
      case LeaderboardPeriod.daily:
        return 'Today\'s rankings';
      case LeaderboardPeriod.weekly:
        return 'This week\'s rankings';
      case LeaderboardPeriod.allTime:
        return 'Overall rankings';
    }
  }
}

/// Leaderboard types
enum LeaderboardType {
  /// Global leaderboard (all users who opted in)
  global,

  /// Friends-only leaderboard
  friends;

  /// Get display name
  String get displayName {
    switch (this) {
      case LeaderboardType.global:
        return 'Global';
      case LeaderboardType.friends:
        return 'Friends';
    }
  }

  /// Get description
  String get description {
    switch (this) {
      case LeaderboardType.global:
        return 'Compete with everyone';
      case LeaderboardType.friends:
        return 'Compete with friends';
    }
  }

  /// Get icon
  String get icon {
    switch (this) {
      case LeaderboardType.global:
        return '🌍';
      case LeaderboardType.friends:
        return '👥';
    }
  }
}
