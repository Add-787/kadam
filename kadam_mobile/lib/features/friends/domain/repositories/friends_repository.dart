import 'package:dartz/dartz.dart';
import '../entities/friend.dart';
import '../entities/friend_request.dart';

/// Repository interface for friend-related operations
/// Defines the contract for friend data access
abstract class FriendsRepository {
  /// Get list of current user's friends
  Future<Either<FriendException, List<Friend>>> getFriends(String userId);

  /// Get a specific friend by userId
  Future<Either<FriendException, Friend>> getFriend(
    String userId,
    String friendId,
  );

  /// Send a friend request to another user
  Future<Either<FriendException, FriendRequest>> sendFriendRequest(
    String fromUserId,
    String toUserId,
  );

  /// Get all pending friend requests (incoming and outgoing)
  Future<Either<FriendException, List<FriendRequest>>> getFriendRequests(
    String userId,
  );

  /// Get incoming friend requests
  Future<Either<FriendException, List<FriendRequest>>> getIncomingRequests(
    String userId,
  );

  /// Get outgoing friend requests
  Future<Either<FriendException, List<FriendRequest>>> getOutgoingRequests(
    String userId,
  );

  /// Accept a friend request
  Future<Either<FriendException, void>> acceptFriendRequest(
    String requestId,
    String userId,
  );

  /// Reject a friend request
  Future<Either<FriendException, void>> rejectFriendRequest(
    String requestId,
    String userId,
  );

  /// Cancel a friend request (sender only)
  Future<Either<FriendException, void>> cancelFriendRequest(
    String requestId,
    String userId,
  );

  /// Remove a friend
  Future<Either<FriendException, void>> removeFriend(
    String userId,
    String friendId,
  );

  /// Block a user
  Future<Either<FriendException, void>> blockUser(
    String userId,
    String blockedUserId,
    String? reason,
  );

  /// Unblock a user
  Future<Either<FriendException, void>> unblockUser(
    String userId,
    String blockedUserId,
  );

  /// Get list of blocked users
  Future<Either<FriendException, List<String>>> getBlockedUsers(String userId);

  /// Check if a user is blocked
  Future<Either<FriendException, bool>> isUserBlocked(
    String userId,
    String otherUserId,
  );

  /// Search users by display name or email
  Future<Either<FriendException, List<Friend>>> searchUsers(
    String query,
    String currentUserId,
  );

  /// Update friend permissions
  Future<Either<FriendException, void>> updateFriendPermissions(
    String userId,
    String friendId,
    bool canViewHistory,
  );

  /// Listen to friends updates (real-time)
  Stream<Either<FriendException, List<Friend>>> watchFriends(String userId);

  /// Listen to friend requests updates (real-time)
  Stream<Either<FriendException, List<FriendRequest>>> watchFriendRequests(
    String userId,
  );
}

/// Exception types for friend operations
class FriendException implements Exception {
  final String message;
  final FriendErrorType type;

  const FriendException(this.message, this.type);

  @override
  String toString() => 'FriendException: $message (${type.name})';
}

/// Types of friend-related errors
enum FriendErrorType {
  /// Network or connectivity error
  network,

  /// User not found
  userNotFound,

  /// Friend request already exists
  requestAlreadyExists,

  /// Already friends
  alreadyFriends,

  /// User is blocked
  userBlocked,

  /// Permission denied
  permissionDenied,

  /// Invalid operation
  invalidOperation,

  /// Server error
  serverError,

  /// Unknown error
  unknown,
}
