import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_entry.dart';

/// Data model for LeaderboardEntry with Firestore serialization
class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.userId,
    required super.displayName,
    super.photoUrl,
    required super.rank,
    required super.steps,
    required super.distance,
    required super.streak,
    required super.lastUpdated,
  });

  /// Create from Firestore document
  factory LeaderboardEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return LeaderboardEntryModel.fromJson(data);
  }

  /// Create from JSON map
  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      rank: json['rank'] as int,
      steps: json['steps'] as int,
      distance: (json['distance'] as num).toDouble(),
      streak: json['streak'] as int,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'rank': rank,
      'steps': steps,
      'distance': distance,
      'streak': streak,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'rank': rank,
      'steps': steps,
      'distance': distance,
      'streak': streak,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Create from domain entity
  factory LeaderboardEntryModel.fromEntity(LeaderboardEntry entity) {
    return LeaderboardEntryModel(
      userId: entity.userId,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      rank: entity.rank,
      steps: entity.steps,
      distance: entity.distance,
      streak: entity.streak,
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Convert to domain entity
  LeaderboardEntry toEntity() {
    return LeaderboardEntry(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      rank: rank,
      steps: steps,
      distance: distance,
      streak: streak,
      lastUpdated: lastUpdated,
    );
  }

  /// Create a copy with updated fields
  LeaderboardEntryModel copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    int? rank,
    int? steps,
    double? distance,
    int? streak,
    DateTime? lastUpdated,
  }) {
    return LeaderboardEntryModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      rank: rank ?? this.rank,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      streak: streak ?? this.streak,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
