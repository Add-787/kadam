import 'package:flutter/material.dart';

/// Settings entity - pure Dart class representing settings domain model
class Settings {
  final ThemeMode themeMode;
  final String languageCode;

  const Settings({
    required this.themeMode,
    this.languageCode = 'en',
  });

  /// Create a copy with updated fields
  Settings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.themeMode == themeMode &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode => Object.hash(themeMode, languageCode);
}
