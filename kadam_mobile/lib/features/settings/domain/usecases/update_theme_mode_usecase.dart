import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

/// UseCase for updating theme mode
class UpdateThemeModeUseCase {
  final SettingsRepository repository;

  UpdateThemeModeUseCase(this.repository);

  Future<void> call(ThemeMode themeMode) async {
    await repository.updateThemeMode(themeMode);
  }
}
