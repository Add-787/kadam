import 'package:equatable/equatable.dart';

/// Domain entity representing a friend relationship
/// Contains business logic and pure data without external dependencies
class Friend extends Equatable {
  /// The friend's unique user ID
  final String userId;

  /// The friend's display name
  final String displayName;

  /// The friend's profile photo URL (optional)
  final String? photoURL;

  /// When the friendship was established
  final DateTime friendsSince;

  /// The friend's current step count for today
  final int currentSteps;

  /// The friend's current streak (consecutive days with activity)
  final int currentStreak;

  /// The friend's Kadam score
  final int kadamScore;

  /// Whether the friend is currently online/active
  final bool isOnline;

  /// Current rank among mutual friends
  final int? rank;

  /// Whether user can view this friend's detailed activity
  final bool canViewActivity;

  /// Whether user can view this friend's history
  final bool canViewHistory;

  /// Last time the friend's data was updated
  final DateTime lastUpdated;

  const Friend({
    required this.userId,
    required this.displayName,
    this.photoURL,
    required this.friendsSince,
    required this.currentSteps,
    required this.currentStreak,
    required this.kadamScore,
    this.isOnline = false,
    this.rank,
    this.canViewActivity = true,
    this.canViewHistory = false,
    required this.lastUpdated,
  });

  /// Calculate days since friendship was established
  int get daysSinceFriendship {
    return DateTime.now().difference(friendsSince).inDays;
  }

  /// Check if this is a new friendship (less than 7 days)
  bool get isNewFriend {
    return daysSinceFriendship < 7;
  }

  /// Check if friend has an active streak
  bool get hasActiveStreak {
    return currentStreak > 0;
  }

  /// Check if friend has reached daily goal (assuming 10k default)
  bool hasReachedDailyGoal([int goal = 10000]) {
    return currentSteps >= goal;
  }

  /// Get friendship duration in a human-readable format
  String get friendshipDuration {
    final days = daysSinceFriendship;
    if (days < 7) {
      return '$days day${days == 1 ? '' : 's'}';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'}';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months month${months == 1 ? '' : 's'}';
    } else {
      final years = (days / 365).floor();
      return '$years year${years == 1 ? '' : 's'}';
    }
  }

  /// Compare this friend with another by steps (for ranking)
  int compareBySteps(Friend other) {
    return other.currentSteps.compareTo(currentSteps);
  }

  /// Compare this friend with another by Kadam score
  int compareByScore(Friend other) {
    return other.kadamScore.compareTo(kadamScore);
  }

  /// Compare this friend with another by streak
  int compareByStreak(Friend other) {
    return other.currentStreak.compareTo(currentStreak);
  }

  /// Create a copy with updated fields
  Friend copyWith({
    String? userId,
    String? displayName,
    String? photoURL,
    DateTime? friendsSince,
    int? currentSteps,
    int? currentStreak,
    int? kadamScore,
    bool? isOnline,
    int? rank,
    bool? canViewActivity,
    bool? canViewHistory,
    DateTime? lastUpdated,
  }) {
    return Friend(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      friendsSince: friendsSince ?? this.friendsSince,
      currentSteps: currentSteps ?? this.currentSteps,
      currentStreak: currentStreak ?? this.currentStreak,
      kadamScore: kadamScore ?? this.kadamScore,
      isOnline: isOnline ?? this.isOnline,
      rank: rank ?? this.rank,
      canViewActivity: canViewActivity ?? this.canViewActivity,
      canViewHistory: canViewHistory ?? this.canViewHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        photoURL,
        friendsSince,
        currentSteps,
        currentStreak,
        kadamScore,
        isOnline,
        rank,
        canViewActivity,
        canViewHistory,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'Friend(userId: $userId, displayName: $displayName, currentSteps: $currentSteps, kadamScore: $kadamScore)';
  }
}
