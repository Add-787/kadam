import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/settings_model.dart';

/// Local data source for settings using SharedPreferences
class SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSource(this.sharedPreferences);

  /// Load settings from local storage
  Future<SettingsModel> loadSettings() async {
    final themeString = sharedPreferences.getString(AppConstants.themeKey);
    final languageCode = sharedPreferences.getString(AppConstants.languageKey);

    return SettingsModel(
      themeMode: _themeModeFromString(themeString ?? 'system'),
      languageCode: languageCode ?? 'en',
    );
  }

  /// Save theme mode to local storage
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await sharedPreferences.setString(
      AppConstants.themeKey,
      _themeModeToString(themeMode),
    );
  }

  /// Save language to local storage
  Future<void> saveLanguage(String languageCode) async {
    await sharedPreferences.setString(
      AppConstants.languageKey,
      languageCode,
    );
  }

  /// Save complete settings
  Future<void> saveSettings(SettingsModel settings) async {
    await saveThemeMode(settings.themeMode);
    await saveLanguage(settings.languageCode);
  }

  // Helper methods
  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _themeModeFromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
