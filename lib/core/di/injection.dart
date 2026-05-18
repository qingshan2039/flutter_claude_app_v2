import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// 全局 [GetIt] 单例。所有依赖通过 [configureDependencies] 在启动时注册。
///
/// 用法（启动期，T13.1 编排）：
/// ```dart
/// await configureDependencies();
/// ```
///
/// 测试中重置（每个测试 setUp 调用）：
/// ```dart
/// await getIt.reset();
/// await configureDependencies();
/// ```
final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<GetIt> configureDependencies({String? environment}) async {
  return getIt.init(environment: environment);
}
