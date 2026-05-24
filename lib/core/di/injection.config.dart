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
import 'package:flutter_claude_app_v2/core/logger/app_logger.dart' as _i236;
import 'package:flutter_claude_app_v2/core/logger/crash_reporter.dart' as _i13;
import 'package:flutter_claude_app_v2/core/logger/performance_monitor.dart'
    as _i851;
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
import 'package:flutter_claude_app_v2/core/observer/provider_observer.dart'
    as _i666;
import 'package:flutter_claude_app_v2/core/permission/permission_service.dart'
    as _i14;
import 'package:flutter_claude_app_v2/core/privacy/account_deletion.dart'
    as _i562;
import 'package:flutter_claude_app_v2/core/privacy/consent_store.dart' as _i88;
import 'package:flutter_claude_app_v2/core/privacy/data_export.dart' as _i655;
import 'package:flutter_claude_app_v2/core/privacy/sdk_initializer.dart'
    as _i587;
import 'package:flutter_claude_app_v2/core/privacy/user_data_eraser.dart'
    as _i405;
import 'package:flutter_claude_app_v2/core/router/app_router.dart' as _i1006;
import 'package:flutter_claude_app_v2/core/router/router_log_observer.dart'
    as _i273;
import 'package:flutter_claude_app_v2/core/security/device_integrity.dart'
    as _i878;
import 'package:flutter_claude_app_v2/core/security/screen_security.dart'
    as _i737;
import 'package:flutter_claude_app_v2/core/storage/database/app_database.dart'
    as _i920;
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart'
    as _i858;
import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart'
    as _i830;
import 'package:flutter_claude_app_v2/core/storage/secure_token_storage.dart'
    as _i8;
import 'package:flutter_claude_app_v2/core/update/platform/android_in_app_update.dart'
    as _i53;
import 'package:flutter_claude_app_v2/core/update/platform/apk_updater.dart'
    as _i123;
import 'package:flutter_claude_app_v2/core/update/platform/store_launcher.dart'
    as _i600;
import 'package:flutter_claude_app_v2/core/update/update_manager.dart' as _i731;
import 'package:flutter_claude_app_v2/core/update/version_check_service.dart'
    as _i50;
import 'package:flutter_claude_app_v2/core/utils/app_info.dart' as _i642;
import 'package:flutter_claude_app_v2/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i143;
import 'package:flutter_claude_app_v2/features/auth/data/repositories/auth_repository_impl.dart'
    as _i56;
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart'
    as _i1049;
import 'package:flutter_claude_app_v2/features/auth/domain/use_cases/get_current_user_use_case.dart'
    as _i5;
import 'package:flutter_claude_app_v2/features/auth/domain/use_cases/sign_in_use_case.dart'
    as _i790;
import 'package:flutter_claude_app_v2/features/detail/data/repositories/detail_repository_impl.dart'
    as _i476;
import 'package:flutter_claude_app_v2/features/detail/domain/repositories/detail_repository.dart'
    as _i426;
import 'package:flutter_claude_app_v2/features/home/data/repositories/home_repository_impl.dart'
    as _i275;
import 'package:flutter_claude_app_v2/features/home/domain/repositories/home_repository.dart'
    as _i749;
import 'package:flutter_claude_app_v2/shared/utils/overlay_utils.dart' as _i364;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final databaseModule = _$DatabaseModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final exampleApiModule = _$ExampleApiModule();
    gh.factory<_i237.FactoryService>(() => _i237.FactoryService());
    gh.singleton<_i591.EagerSingletonService>(
      () => _i591.EagerSingletonService(),
    );
    gh.lazySingleton<_i20.ErrorMapper>(() => const _i20.ErrorMapper());
    gh.lazySingleton<_i462.CancelTokenManager>(
      () => _i462.CancelTokenManager(),
    );
    gh.lazySingleton<_i860.LoggingInterceptor>(
      () => networkModule.provideLoggingInterceptor(),
    );
    gh.lazySingleton<_i260.RetryInterceptor>(
      () => networkModule.provideRetryInterceptor(),
    );
    gh.lazySingleton<_i942.ApiErrorInterceptor>(
      () => const _i942.ApiErrorInterceptor(),
    );
    gh.lazySingleton<_i666.AppProviderObserver>(
      () => _i666.AppProviderObserver(),
    );
    gh.lazySingleton<_i655.DataExportService>(() => _i655.DataExportService());
    gh.lazySingleton<_i587.SdkInitializer>(() => _i587.SdkInitializer());
    gh.lazySingleton<_i273.RouterLogObserver>(() => _i273.RouterLogObserver());
    await gh.lazySingletonAsync<_i920.AppDatabase>(
      () => databaseModule.provideAppDatabase(),
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i642.AppInfo>(() => _i642.AppInfo());
    gh.lazySingleton<_i364.OverlayService>(() => _i364.OverlayService());
    gh.lazySingleton<_i426.DetailRepository>(
      () => const _i476.DetailRepositoryImpl(),
    );
    gh.lazySingleton<_i143.AuthRemoteDataSource>(
      () => const _i143.AuthRemoteDataSourceImpl(),
    );
    gh.lazySingleton<_i1006.RouterDeps>(
      () => _i1006.RouterDeps(gh<_i273.RouterLogObserver>()),
    );
    gh.lazySingleton<_i13.CrashReporter>(() => const _i13.NoopCrashReporter());
    gh.lazySingleton<_i1015.TokenRefresher>(
      () => const _i1015.StubTokenRefresher(),
    );
    gh.lazySingleton<_i236.AppLogger>(() => _i236.LoggerImpl());
    gh.lazySingleton<_i749.HomeRepository>(
      () => const _i275.HomeRepositoryImpl(),
    );
    gh.lazySingleton<_i878.DeviceIntegrityService>(
      () => const _i878.DeviceIntegrityServiceImpl(),
    );
    gh.lazySingleton<_i50.VersionCheckService>(
      () => const _i50.StubVersionCheckService(),
    );
    gh.lazySingleton<_i830.SecureStorage>(
      () => _i830.FlutterSecureStorageImpl(),
    );
    gh.lazySingleton<_i14.PermissionGateway>(
      () => const _i14.PermissionHandlerGateway(),
    );
    gh.lazySingleton<_i767.ApiClient>(
      () => _i767.MockApiClient(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i737.ScreenSecurity>(
      () => const _i737.ScreenSecurityImpl(),
    );
    gh.lazySingleton<_i1015.AuthEvents>(() => const _i1015.NoopAuthEvents());
    gh.lazySingleton<_i600.StoreLauncher>(
      () => const _i600.StoreLauncherImpl(),
    );
    gh.lazySingleton<_i53.AndroidInAppUpdate>(
      () => const _i53.AndroidInAppUpdateImpl(),
    );
    gh.lazySingleton<_i123.ApkUpdater>(() => _i123.ApkUpdaterImpl());
    gh.lazySingleton<_i767.ApiClient>(
      () => _i767.RealApiClient(),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i858.KeyValueStorage>(
      () => _i858.SharedPreferencesStorage(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i731.UpdateManager>(
      () => _i731.UpdateManager(gh<_i50.VersionCheckService>()),
    );
    gh.lazySingleton<_i851.PerformanceMonitor>(
      () => _i851.PerformanceMonitorImpl(gh<_i236.AppLogger>()),
    );
    gh.lazySingleton<_i88.ConsentStore>(
      () => _i88.ConsentStore(gh<_i858.KeyValueStorage>()),
    );
    gh.lazySingleton<_i1015.TokenStorage>(
      () => _i8.SecureTokenStorage(gh<_i830.SecureStorage>()),
    );
    gh.lazySingleton<_i14.PermissionService>(
      () => _i14.PermissionServiceImpl(gh<_i14.PermissionGateway>()),
    );
    gh.lazySingleton<_i405.UserDataEraser>(
      () => _i405.DefaultUserDataEraser(
        gh<_i858.KeyValueStorage>(),
        gh<_i830.SecureStorage>(),
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
    gh.lazySingleton<_i562.AccountDeletionService>(
      () => _i562.AccountDeletionService(
        gh<_i858.KeyValueStorage>(),
        gh<_i405.UserDataEraser>(),
      ),
    );
    gh.lazySingleton<_i1049.AuthRepository>(
      () => _i56.AuthRepositoryImpl(
        gh<_i143.AuthRemoteDataSource>(),
        gh<_i1015.TokenStorage>(),
        gh<_i20.ErrorMapper>(),
      ),
    );
    gh.lazySingleton<_i958.ExampleApiService>(
      () => exampleApiModule.exampleApi(gh<_i361.Dio>()),
    );
    gh.factory<_i5.GetCurrentUserUseCase>(
      () => _i5.GetCurrentUserUseCase(gh<_i1049.AuthRepository>()),
    );
    gh.factory<_i790.SignInUseCase>(
      () => _i790.SignInUseCase(gh<_i1049.AuthRepository>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i29.NetworkModule {}

class _$DatabaseModule extends _i920.DatabaseModule {}

class _$SharedPreferencesModule extends _i858.SharedPreferencesModule {}

class _$ExampleApiModule extends _i958.ExampleApiModule {}
