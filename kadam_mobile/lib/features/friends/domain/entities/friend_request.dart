import 'package:equatable/equatable.dart';

/// Domain entity representing a friend request
class FriendRequest extends Equatable {
  /// Unique request ID
  final String requestId;

  /// User ID of the person who sent the request
  final String fromUserId;

  /// Display name of the sender
  final String fromDisplayName;

  /// Profile photo of the sender
  final String? fromPhotoURL;

  /// User ID of the person receiving the request
  final String toUserId;

  /// Current status of the request
  final FriendRequestStatus status;

  /// Type of request from the current user's perspective
  final FriendRequestType type;

  /// When the request was sent
  final DateTime sentAt;

  /// When the request was responded to (accepted/rejected)
  final DateTime? respondedAt;

  /// When the request will expire (optional, e.g., 30 days)
  final DateTime? expiresAt;

  /// Optional message from the sender
  final String? message;

  const FriendRequest({
    required this.requestId,
    required this.fromUserId,
    required this.fromDisplayName,
    this.fromPhotoURL,
    required this.toUserId,
    required this.status,
    required this.type,
    required this.sentAt,
    this.respondedAt,
    this.expiresAt,
    this.message,
  });

  /// Check if the request is still pending
  bool get isPending => status == FriendRequestStatus.pending;

  /// Check if the request was accepted
  bool get isAccepted => status == FriendRequestStatus.accepted;

  /// Check if the request was rejected
  bool get isRejected => status == FriendRequestStatus.rejected;

  /// Check if the request was cancelled
  bool get isCancelled => status == FriendRequestStatus.cancelled;

  /// Check if the request has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if this is an incoming request (for the current user)
  bool get isIncoming => type == FriendRequestType.incoming;

  /// Check if this is an outgoing request (from the current user)
  bool get isOutgoing => type == FriendRequestType.outgoing;

  /// Get time since request was sent
  Duration get timeSinceRequest {
    return DateTime.now().difference(sentAt);
  }

  /// Get human-readable time since request
  String get timeSinceRequestString {
    final duration = timeSinceRequest;

    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Create a copy with updated fields
  FriendRequest copyWith({
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
    return FriendRequest(
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

  @override
  List<Object?> get props => [
        requestId,
        fromUserId,
        fromDisplayName,
        fromPhotoURL,
        toUserId,
        status,
        type,
        sentAt,
        respondedAt,
        expiresAt,
        message,
      ];

  @override
  String toString() {
    return 'FriendRequest(requestId: $requestId, from: $fromUserId, to: $toUserId, status: $status, type: $type)';
  }
}

/// Status of a friend request
enum FriendRequestStatus {
  /// Request is pending a response
  pending,

  /// Request was accepted
  accepted,

  /// Request was rejected
  rejected,

  /// Request was cancelled by sender
  cancelled,
}

/// Type of friend request from user's perspective
enum FriendRequestType {
  /// Request received by the user
  incoming,

  /// Request sent by the user
  outgoing,
}

/// Extension to convert string to enum
extension FriendRequestStatusExtension on String {
  FriendRequestStatus toFriendRequestStatus() {
    switch (toLowerCase()) {
      case 'pending':
        return FriendRequestStatus.pending;
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      case 'cancelled':
        return FriendRequestStatus.cancelled;
      default:
        return FriendRequestStatus.pending;
    }
  }
}

extension FriendRequestTypeExtension on String {
  FriendRequestType toFriendRequestType() {
    switch (toLowerCase()) {
      case 'incoming':
        return FriendRequestType.incoming;
      case 'outgoing':
        return FriendRequestType.outgoing;
      default:
        return FriendRequestType.incoming;
    }
  }
}

extension FriendRequestStatusStringExtension on FriendRequestStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension FriendRequestTypeStringExtension on FriendRequestType {
  String toShortString() {
    return toString().split('.').last;
  }
}
