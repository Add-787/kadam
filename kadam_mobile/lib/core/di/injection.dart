import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../platform/services/health_platform_service.dart';
import '../platform/channels/health_channel.dart';
import '../platform/channels/mock_health_channel.dart';
import '../platform/factories/health_channel_factory.dart';
import '../../config/environment.dart';
import '../../features/health/presentation/providers/health_platform_provider.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth;

final getIt = GetIt.instance;

/// Setup dependency injection
Future<void> setupDependencyInjection() async {
  // Firebase Auth instance (external dependency)
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  // Auth Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<FirebaseAuth>()),
  );

  // Auth Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Auth Use Cases
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignInWithEmailPasswordUseCase>(
    () => SignInWithEmailPasswordUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignUpWithEmailPasswordUseCase>(
    () => SignUpWithEmailPasswordUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );

  // Auth Provider
  getIt.registerFactory<auth.AuthProvider>(
    () => auth.AuthProvider(
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      signInUseCase: getIt<SignInWithEmailPasswordUseCase>(),
      signUpUseCase: getIt<SignUpWithEmailPasswordUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
    ),
  );

  // Health Channel - inject based on environment
  getIt.registerSingletonAsync<HealthChannel>(
    () async {
        // Use real platform channel (Health Connect/Apple Health)
        final channel = await HealthChannelFactory.create();
        if (channel == null) {
          throw Exception('No health platform available on this device');
        }
        return channel;
      }
  );
  await getIt.isReady<HealthChannel>();

  // Health Platform Service - with injected channel
  getIt.registerLazySingleton<HealthPlatformService>(
    () => HealthPlatformService(getIt<HealthChannel>()),
  );

  // Health Platform Provider
  getIt.registerFactory<HealthPlatformProvider>(
    () => HealthPlatformProvider(getIt<HealthPlatformService>()),
  );
}

/// Cleanup on app dispose
Future<void> disposeDependencies() async {
  await getIt.reset();
}
