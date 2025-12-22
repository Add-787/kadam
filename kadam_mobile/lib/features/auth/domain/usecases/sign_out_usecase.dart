import '../repositories/auth_repository.dart';

/// UseCase for signing out
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    await repository.signOut();
  }
}
