import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_stats.dart';

/// Data model for LeaderboardStats with Firestore serialization
class LeaderboardStatsModel extends LeaderboardStats {
  const LeaderboardStatsModel({
    required super.totalUsers,
    required super.averageSteps,
    required super.medianSteps,
    required super.topSteps,
    required super.lastUpdated,
  });

  /// Create from Firestore document
  factory LeaderboardStatsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return LeaderboardStatsModel.fromJson(data);
  }

  /// Create from JSON map
  factory LeaderboardStatsModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardStatsModel(
      totalUsers: json['totalUsers'] as int,
      averageSteps: json['averageSteps'] as int,
      medianSteps: json['medianSteps'] as int,
      topSteps: json['topSteps'] as int,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'totalUsers': totalUsers,
      'averageSteps': averageSteps,
      'medianSteps': medianSteps,
      'topSteps': topSteps,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'averageSteps': averageSteps,
      'medianSteps': medianSteps,
      'topSteps': topSteps,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Create from domain entity
  factory LeaderboardStatsModel.fromEntity(LeaderboardStats entity) {
    return LeaderboardStatsModel(
      totalUsers: entity.totalUsers,
      averageSteps: entity.averageSteps,
      medianSteps: entity.medianSteps,
      topSteps: entity.topSteps,
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Convert to domain entity
  LeaderboardStats toEntity() {
    return LeaderboardStats(
      totalUsers: totalUsers,
      averageSteps: averageSteps,
      medianSteps: medianSteps,
      topSteps: topSteps,
      lastUpdated: lastUpdated,
    );
  }

  /// Create a copy with updated fields
  LeaderboardStatsModel copyWith({
    int? totalUsers,
    int? averageSteps,
    int? medianSteps,
    int? topSteps,
    DateTime? lastUpdated,
  }) {
    return LeaderboardStatsModel(
      totalUsers: totalUsers ?? this.totalUsers,
      averageSteps: averageSteps ?? this.averageSteps,
      medianSteps: medianSteps ?? this.medianSteps,
      topSteps: topSteps ?? this.topSteps,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
