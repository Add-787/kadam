import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await remoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final userModel = await remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      return userModel?.toEntity();
    });
  }
}
