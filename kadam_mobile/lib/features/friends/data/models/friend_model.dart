import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend.dart';

/// Data model for Friend that handles Firestore serialization
/// Extends the domain entity with JSON conversion methods
class FriendModel extends Friend {
  const FriendModel({
    required super.userId,
    required super.displayName,
    super.photoURL,
    required super.friendsSince,
    required super.currentSteps,
    required super.currentStreak,
    required super.kadamScore,
    super.isOnline,
    super.rank,
    super.canViewActivity,
    super.canViewHistory,
    required super.lastUpdated,
  });

  /// Create FriendModel from Firestore document
  factory FriendModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FriendModel(
      userId: doc.id,
      displayName: data['displayName'] as String? ?? '',
      photoURL: data['photoURL'] as String?,
      friendsSince: (data['friendsSince'] as Timestamp).toDate(),
      currentSteps: data['currentSteps'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      kadamScore: data['kadamScore'] as int? ?? 0,
      isOnline: data['isOnline'] as bool? ?? false,
      rank: data['rank'] as int?,
      canViewActivity: data['canViewActivity'] as bool? ?? true,
      canViewHistory: data['canViewHistory'] as bool? ?? false,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create FriendModel from JSON map
  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String? ?? '',
      photoURL: json['photoURL'] as String?,
      friendsSince: json['friendsSince'] is Timestamp
          ? (json['friendsSince'] as Timestamp).toDate()
          : DateTime.parse(json['friendsSince'] as String),
      currentSteps: json['currentSteps'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      kadamScore: json['kadamScore'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      rank: json['rank'] as int?,
      canViewActivity: json['canViewActivity'] as bool? ?? true,
      canViewHistory: json['canViewHistory'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] is Timestamp
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoURL': photoURL,
      'friendsSince': Timestamp.fromDate(friendsSince),
      'currentSteps': currentSteps,
      'currentStreak': currentStreak,
      'kadamScore': kadamScore,
      'isOnline': isOnline,
      'rank': rank,
      'canViewActivity': canViewActivity,
      'canViewHistory': canViewHistory,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoURL': photoURL,
      'friendsSince': friendsSince.toIso8601String(),
      'currentSteps': currentSteps,
      'currentStreak': currentStreak,
      'kadamScore': kadamScore,
      'isOnline': isOnline,
      'rank': rank,
      'canViewActivity': canViewActivity,
      'canViewHistory': canViewHistory,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Convert domain entity to data model
  factory FriendModel.fromEntity(Friend friend) {
    return FriendModel(
      userId: friend.userId,
      displayName: friend.displayName,
      photoURL: friend.photoURL,
      friendsSince: friend.friendsSince,
      currentSteps: friend.currentSteps,
      currentStreak: friend.currentStreak,
      kadamScore: friend.kadamScore,
      isOnline: friend.isOnline,
      rank: friend.rank,
      canViewActivity: friend.canViewActivity,
      canViewHistory: friend.canViewHistory,
      lastUpdated: friend.lastUpdated,
    );
  }

  /// Convert data model to domain entity
  Friend toEntity() {
    return Friend(
      userId: userId,
      displayName: displayName,
      photoURL: photoURL,
      friendsSince: friendsSince,
      currentSteps: currentSteps,
      currentStreak: currentStreak,
      kadamScore: kadamScore,
      isOnline: isOnline,
      rank: rank,
      canViewActivity: canViewActivity,
      canViewHistory: canViewHistory,
      lastUpdated: lastUpdated,
    );
  }

  /// Create a copy with updated fields
  @override
  FriendModel copyWith({
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
    return FriendModel(
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
}
