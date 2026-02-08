import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> connectedSources;
  final Map<String, dynamic> preferences;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.connectedSources = const [],
    this.preferences = const {},
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime createdAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: documentId,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: createdAt,
      connectedSources: List<String>.from(map['connectedSources'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'connectedSources': connectedSources,
      'preferences': preferences,
    };
  }

  @override
  List<Object?> get props => [id, displayName, email, photoUrl, createdAt, connectedSources, preferences];
}
