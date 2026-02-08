// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/bloc/sign_in_bloc.dart' as _i135;
import '../../features/auth/presentation/bloc/sign_up_bloc.dart' as _i1044;
import '../../features/history/data/repositories/history_repository_impl.dart'
    as _i751;
import '../../features/history/domain/repositories/history_repository.dart'
    as _i142;
import '../../features/history/presentation/bloc/history_bloc.dart' as _i1070;
import '../../features/steps/data/datasources/step_local_data_source.dart'
    as _i264;
import '../../features/steps/data/repositories/step_repository_impl.dart'
    as _i906;
import '../../features/steps/domain/repositories/step_repository.dart' as _i206;
import '../../features/steps/presentation/bloc/steps_bloc.dart' as _i203;
import '../services/firestore_service.dart' as _i52;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i52.FirestoreService>(() => _i52.FirestoreService());
    gh.lazySingleton<_i852.AuthLocalDataSource>(
      () => _i852.AuthLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i264.StepLocalDataSource>(
      () => _i264.StepLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i142.HistoryRepository>(
      () => _i751.HistoryRepositoryImpl(),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i852.AuthLocalDataSource>(),
        gh<_i52.FirestoreService>(),
      ),
    );
    gh.factory<_i135.SignInBloc>(
      () => _i135.SignInBloc(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1044.SignUpBloc>(
      () => _i1044.SignUpBloc(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i206.StepRepository>(
      () => _i906.StepRepositoryImpl(gh<_i264.StepLocalDataSource>()),
    );
    gh.factory<_i1070.HistoryBloc>(
      () => _i1070.HistoryBloc(gh<_i142.HistoryRepository>()),
    );
    gh.factory<_i203.StepsBloc>(
      () => _i203.StepsBloc(
        gh<_i206.StepRepository>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    return this;
  }
}
