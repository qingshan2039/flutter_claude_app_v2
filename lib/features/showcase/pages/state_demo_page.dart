import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/combined_greeting_provider.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/counter_state_notifier.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/user_async_notifier.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// M06 状态管理 — 可视化演示（Riverpod providers）。
class StateDemoPage extends ConsumerWidget {
  const StateDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterStateNotifierProvider);
    final combined = ref.watch(greetingWithCounterProvider);
    final asyncUser = ref.watch(userAsyncNotifierProvider);

    return DemoScaffold(
      title: '状态管理',
      moduleId: 'M06',
      children: <Widget>[
        DemoSection(
          title: 'StateNotifierProvider（同步可变）',
          description: '计数器；变更会被 ProviderObserver 记录到日志',
          child: Row(
            children: <Widget>[
              IconButton.filled(
                onPressed: () =>
                    ref.read(counterStateNotifierProvider.notifier).decrement(),
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              Text('$counter', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: () =>
                    ref.read(counterStateNotifierProvider.notifier).increment(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '组合 Provider（派生）',
          description: 'greeting + counter 自动重算',
          child: Text(combined, style: Theme.of(context).textTheme.titleMedium),
        ),
        DemoSection(
          title: 'AsyncNotifierProvider（异步三态）',
          description: 'AsyncValue.when 处理 loading / data / error',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              asyncUser.when(
                data: (user) => DemoResultRow('data', user.name),
                loading: () => const Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('loading…'),
                  ],
                ),
                error: (e, _) => Text('error: $e'),
              ),
              const SizedBox(height: 8),
              // 主题给按钮设了 minimumSize: Size.fromHeight(48)（即最小宽度无限，
              // 用于 Column 中的整宽按钮）。放进 Row 必须用 Expanded 约束宽度，
              // 否则 Row 以无界宽度测量子项会触发 “infinite width” 断言。
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () => ref
                          .read(userAsyncNotifierProvider.notifier)
                          .refresh(),
                      child: const Text('refresh'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(userAsyncNotifierProvider.notifier)
                          .updateName('Renamed @${DateTime.now().second}'),
                      child: const Text('updateName'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
