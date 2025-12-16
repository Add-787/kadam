import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

/// UseCase for loading settings
class LoadSettingsUseCase {
  final SettingsRepository repository;

  LoadSettingsUseCase(this.repository);

  Future<Settings> call() async {
    return await repository.loadSettings();
  }
}
