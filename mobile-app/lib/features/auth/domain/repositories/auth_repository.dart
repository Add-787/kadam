import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> signInWithEmail(String email, String password);

  Future<UserCredential> signUpWithEmail(String email, String password, {String? username});

  Future<UserCredential?> signInWithGoogle();

  Future<void> signOut();

  Stream<User?> get userStream;

  User? get currentUser;

  Future<DateTime?> getJoinedDate();
}
