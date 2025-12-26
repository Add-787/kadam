import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/rank_history.dart';

/// Data model for RankHistory with Firestore serialization
class RankHistoryModel extends RankHistory {
  const RankHistoryModel({
    required super.date,
    required super.rank,
    required super.steps,
  });

  /// Create from Firestore document
  factory RankHistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return RankHistoryModel.fromJson(data);
  }

  /// Create from JSON map
  factory RankHistoryModel.fromJson(Map<String, dynamic> json) {
    return RankHistoryModel(
      date: json['date'] as String,
      rank: json['rank'] as int,
      steps: json['steps'] as int,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'rank': rank,
      'steps': steps,
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'rank': rank,
      'steps': steps,
    };
  }

  /// Create from domain entity
  factory RankHistoryModel.fromEntity(RankHistory entity) {
    return RankHistoryModel(
      date: entity.date,
      rank: entity.rank,
      steps: entity.steps,
    );
  }

  /// Convert to domain entity
  RankHistory toEntity() {
    return RankHistory(
      date: date,
      rank: rank,
      steps: steps,
    );
  }

  /// Create a copy with updated fields
  RankHistoryModel copyWith({
    String? date,
    int? rank,
    int? steps,
  }) {
    return RankHistoryModel(
      date: date ?? this.date,
      rank: rank ?? this.rank,
      steps: steps ?? this.steps,
    );
  }
}
