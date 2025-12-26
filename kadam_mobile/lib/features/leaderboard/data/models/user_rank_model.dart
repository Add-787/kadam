import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_rank.dart';

/// Data model for UserRank with Firestore serialization
class UserRankModel extends UserRank {
  const UserRankModel({
    required super.userId,
    required super.rank,
    required super.totalUsers,
    required super.steps,
    required super.percentile,
    required super.timestamp,
  });

  /// Create from Firestore document
  factory UserRankModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserRankModel.fromJson(data);
  }

  /// Create from JSON map
  factory UserRankModel.fromJson(Map<String, dynamic> json) {
    return UserRankModel(
      userId: json['userId'] as String,
      rank: json['rank'] as int,
      totalUsers: json['totalUsers'] as int,
      steps: json['steps'] as int,
      percentile: json['percentile'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'rank': rank,
      'totalUsers': totalUsers,
      'steps': steps,
      'percentile': percentile,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'rank': rank,
      'totalUsers': totalUsers,
      'steps': steps,
      'percentile': percentile,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Create from domain entity
  factory UserRankModel.fromEntity(UserRank entity) {
    return UserRankModel(
      userId: entity.userId,
      rank: entity.rank,
      totalUsers: entity.totalUsers,
      steps: entity.steps,
      percentile: entity.percentile,
      timestamp: entity.timestamp,
    );
  }

  /// Convert to domain entity
  UserRank toEntity() {
    return UserRank(
      userId: userId,
      rank: rank,
      totalUsers: totalUsers,
      steps: steps,
      percentile: percentile,
      timestamp: timestamp,
    );
  }

  /// Create a copy with updated fields
  UserRankModel copyWith({
    String? userId,
    int? rank,
    int? totalUsers,
    int? steps,
    int? percentile,
    DateTime? timestamp,
  }) {
    return UserRankModel(
      userId: userId ?? this.userId,
      rank: rank ?? this.rank,
      totalUsers: totalUsers ?? this.totalUsers,
      steps: steps ?? this.steps,
      percentile: percentile ?? this.percentile,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
