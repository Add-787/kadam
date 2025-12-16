import 'package:flutter/material.dart';
import '../../domain/entities/settings.dart';
import '../../domain/usecases/load_settings_usecase.dart';
import '../../domain/usecases/update_theme_mode_usecase.dart';

/// Settings provider for state management
class SettingsProvider with ChangeNotifier {
  final LoadSettingsUseCase loadSettingsUseCase;
  final UpdateThemeModeUseCase updateThemeModeUseCase;

  SettingsProvider({
    required this.loadSettingsUseCase,
    required this.updateThemeModeUseCase,
  });

  Settings _settings = const Settings(themeMode: ThemeMode.system);
  bool _isLoading = false;

  Settings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  bool get isLoading => _isLoading;

  /// Load settings
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await loadSettingsUseCase();
    } catch (e) {
      // Handle error - for now just use default
      _settings = const Settings(themeMode: ThemeMode.system);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _settings.themeMode) {
      return;
    }

    try {
      await updateThemeModeUseCase(newThemeMode);
      _settings = _settings.copyWith(themeMode: newThemeMode);
      notifyListeners();
    } catch (e) {
      // Handle error
      debugPrint('Error updating theme mode: $e');
    }
  }
}
