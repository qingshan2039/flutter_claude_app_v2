import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [FutureProvider] 示例（T06.2）— 异步三态（loading / data / error）。
///
/// 适合场景：
/// - 一次性 async 加载（HTTP GET、磁盘读取）
/// - 由 [ref.watch] 自动追踪依赖：依赖变化时重新加载
///
/// UI 中通常用 [AsyncValue.when] 处理三态：
/// ```dart
/// final asyncUser = ref.watch(userFutureProvider);
/// return asyncUser.when(
///   data: (user) => Text(user.name),
///   loading: () => const CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
///
/// 注：本示例返回固定 [User]，模拟 100ms IO。M19/T19.1 完成后替换为 repository 调用。
final FutureProvider<User> userFutureProvider = FutureProvider<User>(
  (ref) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const User(
      id: 'demo-future-1',
      name: 'Future Demo User',
      email: 'demo@example.com',
    );
  },
  name: 'userFutureProvider',
);
