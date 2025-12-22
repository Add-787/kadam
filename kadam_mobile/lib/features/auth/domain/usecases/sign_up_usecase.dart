import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase for signing up with email and password
class SignUpWithEmailPasswordUseCase {
  final AuthRepository repository;

  SignUpWithEmailPasswordUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
