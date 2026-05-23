import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/features/auth/presentation/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前用户徽标（T17.3 Widget 测试范例的被测组件）。
///
/// 监听 [currentUserProvider]（`AsyncValue<User>`），三态渲染：
/// - data：头像图标 + 用户名
/// - loading：小转圈
/// - error：「加载失败」
///
/// 测试时通过 `ProviderScope.overrides` 注入 mock 的
/// [getCurrentUserUseCaseProvider]，即可控制三态，无需真实 DI / 网络。
class CurrentUserBadge extends ConsumerWidget {
  const CurrentUserBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(currentUserProvider);
    return asyncUser.when(
      data: (user) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.account_circle_outlined, size: 20),
          const SizedBox(width: 8),
          Text(user.name),
        ],
      ),
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const Text('加载失败'),
    );
  }
}
