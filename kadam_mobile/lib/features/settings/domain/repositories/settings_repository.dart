import 'package:flutter/material.dart';
import '../entities/settings.dart';

/// Abstract repository interface for settings
/// This defines what operations are available for settings
abstract class SettingsRepository {
  /// Load settings from storage
  Future<Settings> loadSettings();

  /// Update theme mode
  Future<void> updateThemeMode(ThemeMode themeMode);

  /// Update language
  Future<void> updateLanguage(String languageCode);

  /// Save complete settings
  Future<void> saveSettings(Settings settings);
}
