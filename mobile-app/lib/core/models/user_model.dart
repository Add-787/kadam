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
    return UserModel(
      id: documentId,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
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
