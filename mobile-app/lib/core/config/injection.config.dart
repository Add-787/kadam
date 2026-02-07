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

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i101;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i102;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i103;
import '../../features/auth/presentation/bloc/sign_in_bloc.dart' as _i135;
import '../../features/auth/presentation/bloc/sign_up_bloc.dart' as _i1044;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i101.AuthRemoteDataSource>(
        () => _i101.AuthRemoteDataSourceImpl());
    gh.lazySingleton<_i103.AuthRepository>(
        () => _i102.AuthRepositoryImpl(gh<_i101.AuthRemoteDataSource>()));
    gh.factory<_i135.SignInBloc>(
        () => _i135.SignInBloc(gh<_i103.AuthRepository>()));
    gh.factory<_i1044.SignUpBloc>(
        () => _i1044.SignUpBloc(gh<_i103.AuthRepository>()));
    return this;
  }
}
