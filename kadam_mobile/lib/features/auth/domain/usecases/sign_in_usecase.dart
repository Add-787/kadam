import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase for signing in with email and password
class SignInWithEmailPasswordUseCase {
  final AuthRepository repository;

  SignInWithEmailPasswordUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
