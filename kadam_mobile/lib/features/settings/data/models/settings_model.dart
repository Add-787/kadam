import 'package:flutter/material.dart';
import '../../domain/entities/settings.dart';

/// Settings model for data layer
/// Handles JSON serialization and deserialization
class SettingsModel extends Settings {
  const SettingsModel({
    required super.themeMode,
    super.languageCode,
  });

  /// Create from domain entity
  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      themeMode: settings.themeMode,
      languageCode: settings.languageCode,
    );
  }

  /// Create from JSON (for local storage or API)
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: _themeModeFromString(json['themeMode'] as String? ?? 'system'),
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'themeMode': _themeModeToString(themeMode),
      'languageCode': languageCode,
    };
  }

  /// Convert domain entity to model
  Settings toEntity() {
    return Settings(
      themeMode: themeMode,
      languageCode: languageCode,
    );
  }

  /// Helper: Convert ThemeMode to String
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

  /// Helper: Convert String to ThemeMode
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
