import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [AsyncNotifier] 示例（T06.2）— 异步加载 + 可变操作（refresh / mutate）。
///
/// 与 [FutureProvider] 的区别：[FutureProvider] 是只读异步值；[AsyncNotifier]
/// 既有异步加载，又暴露方法（如 [refresh] / [updateName]）让外部触发变更。
///
/// 适合场景：
/// - 当前用户资料：加载后可在 UI 触发改名
/// - 异步可变列表：加载历史记录 + 增删
///
/// 使用：
/// ```dart
/// final asyncUser = ref.watch(userAsyncNotifierProvider);
/// asyncUser.when(...);
/// ref.read(userAsyncNotifierProvider.notifier).refresh();
/// ```
class UserAsyncNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const User(
      id: 'async-1',
      name: 'Async User',
      email: 'async@example.com',
    );
  }

  /// 重新加载（重新触发 [build]）。返回的 [AsyncValue] 在加载期为 loading。
  Future<void> refresh() async {
    state = const AsyncValue<User>.loading();
    state = await AsyncValue.guard<User>(build);
  }

  /// 模拟修改名字。仅在已有数据时变更，无需重新加载。
  void updateName(String name) {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue<User>.data(current.copyWith(name: name));
    }
  }
}

final AsyncNotifierProvider<UserAsyncNotifier, User> userAsyncNotifierProvider =
    AsyncNotifierProvider<UserAsyncNotifier, User>(
      UserAsyncNotifier.new,
      name: 'userAsyncNotifierProvider',
    );
