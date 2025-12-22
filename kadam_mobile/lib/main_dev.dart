import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options_dev.dart';
import 'app.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth;
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/usecases/load_settings_usecase.dart';
import 'features/settings/domain/usecases/update_theme_mode_usecase.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with DEV configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Setup Auth dependency injection
  final firebaseAuth = FirebaseAuth.instance;
  final authRemoteDataSource = AuthRemoteDataSource(firebaseAuth);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final signInUseCase = SignInWithEmailPasswordUseCase(authRepository);
  final signUpUseCase = SignUpWithEmailPasswordUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);

  // Create auth provider
  final authProvider = auth.AuthProvider(
    getCurrentUserUseCase: getCurrentUserUseCase,
    signInUseCase: signInUseCase,
    signUpUseCase: signUpUseCase,
    signOutUseCase: signOutUseCase,
  );

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

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const App(),
    ),
  );
}
