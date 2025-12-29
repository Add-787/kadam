import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/firebase_options_dev.dart';
import 'shared/presentation/app.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth;
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/usecases/load_settings_usecase.dart';
import 'features/settings/domain/usecases/update_theme_mode_usecase.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/health/presentation/providers/health_platform_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection for health platform and auth
  setupDependencyInjection();

  // Initialize Firebase with DEV configuration (default)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Get auth provider from dependency injection
  final authProvider = getIt<auth.AuthProvider>();

  // Initialize auth state
  await authProvider.initialize();

  // Setup Settings dependency injection
  final settingsLocalDataSource = SettingsLocalDataSource(sharedPreferences);
  final settingsRepository = SettingsRepositoryImpl(settingsLocalDataSource);
  final loadSettingsUseCase = LoadSettingsUseCase(settingsRepository);
  final updateThemeModeUseCase = UpdateThemeModeUseCase(settingsRepository);

  // Create settings provider
  final settingsProvider = SettingsProvider(
    loadSettingsUseCase: loadSettingsUseCase,
    updateThemeModeUseCase: updateThemeModeUseCase,
  );

  // Load initial settings
  await settingsProvider.loadSettings();

  // Get health platform provider from dependency injection
  final healthPlatformProvider = getIt<HealthPlatformProvider>();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: healthPlatformProvider),
      ],
      child: const App(),
    ),
  );
}
