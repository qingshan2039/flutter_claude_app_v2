import 'package:injectable/injectable.dart';

/// `@singleton` 示例：注册时立即实例化，全程仅一个实例。
///
/// 适合场景：
/// - 启动即需可用、生命周期与应用一致（EventBus、SessionManager、ConfigService）
/// - 需要在 `configureDependencies()` 时执行初始化副作用（捕获 [DateTime.now]
///   作为应用启动时间戳）
///
/// 与 `@lazySingleton` 的区别：本类在 `getIt.init()` 调用瞬间就被构造；
/// `@lazySingleton` 在首次 `getIt<T>()` 时才构造。
@singleton
class EagerSingletonService {
  EagerSingletonService() : initializedAt = DateTime.now();

  final DateTime initializedAt;
}
