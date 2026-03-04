import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._firestoreService,
  );

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _remoteDataSource.signInWithEmail(email, password);
    if (credential.user != null) {
      final userProfile = await _firestoreService.getUserProfile(credential.user!.uid);
      if (userProfile != null) {
        await _localDataSource.saveJoinedDate(userProfile.createdAt);
      }
    }
    return credential;
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password, {String? username}) async {
    final credential = await _remoteDataSource.signUpWithEmail(email, password);
    if (credential.user != null) {
      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        displayName: username ?? '',
        email: email,
        createdAt: now,
      );
      
      // Save to Firestore
      await _firestoreService.createUserProfile(userModel);
      
      // Save to SharedPreferences
      await _localDataSource.saveJoinedDate(now);
    }
    return credential;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    final credential = await _remoteDataSource.signInWithGoogle();
    if (credential?.user != null) {
      final userProfile = await _firestoreService.getUserProfile(credential!.user!.uid);
      if (userProfile != null) {
        await _localDataSource.saveJoinedDate(userProfile.createdAt);
      } else {
        // New user from Google
        final now = DateTime.now();
        final userModel = UserModel(
          id: credential.user!.uid,
          displayName: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          createdAt: now,
        );
        await _firestoreService.createUserProfile(userModel);
        await _localDataSource.saveJoinedDate(now);
      }
    }
    return credential;
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Stream<User?> get userStream => _remoteDataSource.userStream;

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<DateTime?> getJoinedDate() async {
    // Try local first
    final localDate = await _localDataSource.getJoinedDate();
    if (localDate != null) return localDate;

    // If not in local, try Firestore
    if (currentUser != null) {
      final userProfile = await _firestoreService.getUserProfile(currentUser!.uid);
      if (userProfile != null) {
        await _localDataSource.saveJoinedDate(userProfile.createdAt);
        return userProfile.createdAt;
      }
    }
    return null;
  }
}
