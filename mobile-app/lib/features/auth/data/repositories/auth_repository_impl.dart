import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserCredential> signInWithEmail(String email, String password) =>
      _remoteDataSource.signInWithEmail(email, password);

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) =>
      _remoteDataSource.signUpWithEmail(email, password);

  @override
  Future<UserCredential?> signInWithGoogle() =>
      _remoteDataSource.signInWithGoogle();

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Stream<User?> get userStream => _remoteDataSource.userStream;

  @override
  User? get currentUser => _remoteDataSource.currentUser;
}
