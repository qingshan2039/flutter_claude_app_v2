// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_claude_app_v2/core/di/examples/eager_singleton_service.dart'
    as _i591;
import 'package:flutter_claude_app_v2/core/di/examples/environment_aware_service.dart'
    as _i767;
import 'package:flutter_claude_app_v2/core/di/examples/factory_service.dart'
    as _i237;
import 'package:flutter_claude_app_v2/core/error/error_mapper.dart' as _i20;
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
    gh.factory<_i237.FactoryService>(() => _i237.FactoryService());
    gh.singleton<_i591.EagerSingletonService>(
      () => _i591.EagerSingletonService(),
    );
    gh.lazySingleton<_i20.ErrorMapper>(() => const _i20.ErrorMapper());
    gh.lazySingleton<_i642.AppInfo>(() => _i642.AppInfo());
    gh.lazySingleton<_i767.ApiClient>(
      () => _i767.MockApiClient(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i767.ApiClient>(
      () => _i767.RealApiClient(),
      registerFor: {_prod},
    );
    return this;
  }
}
