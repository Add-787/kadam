import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend_request.dart';

/// Data model for FriendRequest that handles Firestore serialization
class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.requestId,
    required super.fromUserId,
    required super.fromDisplayName,
    super.fromPhotoURL,
    required super.toUserId,
    required super.status,
    required super.type,
    required super.sentAt,
    super.respondedAt,
    super.expiresAt,
    super.message,
  });

  /// Create FriendRequestModel from Firestore document
  factory FriendRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FriendRequestModel(
      requestId: doc.id,
      fromUserId: data['fromUserId'] as String,
      fromDisplayName: data['fromDisplayName'] as String? ?? '',
      fromPhotoURL: data['fromPhotoURL'] as String?,
      toUserId: data['toUserId'] as String,
      status: (data['status'] as String).toFriendRequestStatus(),
      type: (data['type'] as String).toFriendRequestType(),
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      message: data['message'] as String?,
    );
  }

  /// Create FriendRequestModel from JSON map
  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requestId: json['requestId'] as String,
      fromUserId: json['fromUserId'] as String,
      fromDisplayName: json['fromDisplayName'] as String? ?? '',
      fromPhotoURL: json['fromPhotoURL'] as String?,
      toUserId: json['toUserId'] as String,
      status: (json['status'] as String).toFriendRequestStatus(),
      type: (json['type'] as String).toFriendRequestType(),
      sentAt: json['sentAt'] is Timestamp
          ? (json['sentAt'] as Timestamp).toDate()
          : DateTime.parse(json['sentAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] is Timestamp
              ? (json['respondedAt'] as Timestamp).toDate()
              : DateTime.parse(json['respondedAt'] as String))
          : null,
      expiresAt: json['expiresAt'] != null
          ? (json['expiresAt'] is Timestamp
              ? (json['expiresAt'] as Timestamp).toDate()
              : DateTime.parse(json['expiresAt'] as String))
          : null,
      message: json['message'] as String?,
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromDisplayName': fromDisplayName,
      'fromPhotoURL': fromPhotoURL,
      'toUserId': toUserId,
      'status': status.toShortString(),
      'type': type.toShortString(),
      'sentAt': Timestamp.fromDate(sentAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'message': message,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'fromUserId': fromUserId,
      'fromDisplayName': fromDisplayName,
      'fromPhotoURL': fromPhotoURL,
      'toUserId': toUserId,
      'status': status.toShortString(),
      'type': type.toShortString(),
      'sentAt': sentAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'message': message,
    };
  }

  /// Convert domain entity to data model
  factory FriendRequestModel.fromEntity(FriendRequest request) {
    return FriendRequestModel(
      requestId: request.requestId,
      fromUserId: request.fromUserId,
      fromDisplayName: request.fromDisplayName,
      fromPhotoURL: request.fromPhotoURL,
      toUserId: request.toUserId,
      status: request.status,
      type: request.type,
      sentAt: request.sentAt,
      respondedAt: request.respondedAt,
      expiresAt: request.expiresAt,
      message: request.message,
    );
  }

  /// Convert data model to domain entity
  FriendRequest toEntity() {
    return FriendRequest(
      requestId: requestId,
      fromUserId: fromUserId,
      fromDisplayName: fromDisplayName,
      fromPhotoURL: fromPhotoURL,
      toUserId: toUserId,
      status: status,
      type: type,
      sentAt: sentAt,
      respondedAt: respondedAt,
      expiresAt: expiresAt,
      message: message,
    );
  }

  /// Create a copy with updated fields
  @override
  FriendRequestModel copyWith({
    String? requestId,
    String? fromUserId,
    String? fromDisplayName,
    String? fromPhotoURL,
    String? toUserId,
    FriendRequestStatus? status,
    FriendRequestType? type,
    DateTime? sentAt,
    DateTime? respondedAt,
    DateTime? expiresAt,
    String? message,
  }) {
    return FriendRequestModel(
      requestId: requestId ?? this.requestId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromDisplayName: fromDisplayName ?? this.fromDisplayName,
      fromPhotoURL: fromPhotoURL ?? this.fromPhotoURL,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      message: message ?? this.message,
    );
  }
}
