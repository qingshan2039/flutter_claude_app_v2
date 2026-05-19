// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_claude_app_v2/core/di/examples/eager_singleton_service.dart'
    as _i591;
import 'package:flutter_claude_app_v2/core/di/examples/environment_aware_service.dart'
    as _i767;
import 'package:flutter_claude_app_v2/core/di/examples/factory_service.dart'
    as _i237;
import 'package:flutter_claude_app_v2/core/error/error_mapper.dart' as _i20;
import 'package:flutter_claude_app_v2/core/network/api_service.dart' as _i958;
import 'package:flutter_claude_app_v2/core/network/cancel_token_manager.dart'
    as _i462;
import 'package:flutter_claude_app_v2/core/network/dio_client.dart' as _i29;
import 'package:flutter_claude_app_v2/core/network/interceptors/auth_interceptor.dart'
    as _i1015;
import 'package:flutter_claude_app_v2/core/network/interceptors/error_interceptor.dart'
    as _i942;
import 'package:flutter_claude_app_v2/core/network/interceptors/log_interceptor.dart'
    as _i860;
import 'package:flutter_claude_app_v2/core/network/interceptors/retry_interceptor.dart'
    as _i260;
import 'package:flutter_claude_app_v2/core/utils/app_info.dart' as _i642;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final exampleApiModule = _$ExampleApiModule();
    gh.factory<_i237.FactoryService>(() => _i237.FactoryService());
    gh.singleton<_i591.EagerSingletonService>(
      () => _i591.EagerSingletonService(),
    );
    gh.lazySingleton<_i20.ErrorMapper>(() => const _i20.ErrorMapper());
    gh.lazySingleton<_i462.CancelTokenManager>(
      () => _i462.CancelTokenManager(),
    );
    gh.lazySingleton<_i942.ApiErrorInterceptor>(
      () => const _i942.ApiErrorInterceptor(),
    );
    gh.lazySingleton<_i642.AppInfo>(() => _i642.AppInfo());
    gh.lazySingleton<_i1015.TokenRefresher>(
      () => const _i1015.StubTokenRefresher(),
    );
    gh.lazySingleton<_i260.RetryInterceptor>(
      () => _i260.RetryInterceptor(
        maxRetries: gh<int>(),
        baseDelay: gh<Duration>(),
      ),
    );
    gh.lazySingleton<_i767.ApiClient>(
      () => _i767.MockApiClient(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i1015.AuthEvents>(() => const _i1015.NoopAuthEvents());
    gh.lazySingleton<_i1015.TokenStorage>(() => _i1015.InMemoryTokenStorage());
    gh.lazySingleton<_i860.LoggingInterceptor>(
      () => _i860.LoggingInterceptor(
        enabled: gh<bool>(),
        extraSensitiveHeaders: gh<Set<String>>(),
        extraSensitiveBodyKeys: gh<Set<String>>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.provideDio(
        gh<_i1015.TokenStorage>(),
        gh<_i1015.TokenRefresher>(),
        gh<_i1015.AuthEvents>(),
        gh<_i860.LoggingInterceptor>(),
        gh<_i260.RetryInterceptor>(),
        gh<_i942.ApiErrorInterceptor>(),
      ),
    );
    gh.lazySingleton<_i767.ApiClient>(
      () => _i767.RealApiClient(),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i958.ExampleApiService>(
      () => exampleApiModule.exampleApi(gh<_i361.Dio>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i29.NetworkModule {}

class _$ExampleApiModule extends _i958.ExampleApiModule {}
