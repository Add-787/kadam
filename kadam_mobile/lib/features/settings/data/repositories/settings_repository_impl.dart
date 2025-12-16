import 'package:flutter/material.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

/// Implementation of SettingsRepository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Settings> loadSettings() async {
    final settingsModel = await localDataSource.loadSettings();
    return settingsModel.toEntity();
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await localDataSource.saveThemeMode(themeMode);
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    await localDataSource.saveLanguage(languageCode);
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    final settingsModel = SettingsModel.fromEntity(settings);
    await localDataSource.saveSettings(settingsModel);
  }
}
