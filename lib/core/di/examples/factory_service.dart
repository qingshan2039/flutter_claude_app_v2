import 'package:injectable/injectable.dart';

/// `@injectable` 示例：每次 `getIt<T>()` 都返回新实例（factory 语义）。
///
/// 适合场景：
/// - 无共享状态的工具（请求级 ID 生成器、UUID 生成器）
/// - 每次表单 / 弹窗都需要全新状态的对象
///
/// 区别于 `@singleton` / `@lazySingleton`：本类**没有**实例缓存。
@injectable
class FactoryService {
  FactoryService() : createdAt = DateTime.now();

  final DateTime createdAt;
}
