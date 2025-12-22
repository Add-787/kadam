import '../entities/user.dart';

/// Abstract repository interface for authentication
abstract class AuthRepository {
  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Listen to auth state changes
  Stream<User?> get authStateChanges;
}
