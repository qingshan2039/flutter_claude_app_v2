import 'package:flutter_claude_app_v2/features/examples/providers_demo/counter_state_notifier.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/greeting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 组合 Provider 示例（T06.2）— 把 [greetingProvider] 与 [counterStateNotifierProvider]
/// 派生为一个新的字符串。
///
/// 自动重算：任一上游变化时，[ref.watch] 会触发本 provider 重新构建。
/// 这是 Riverpod 的核心能力：派生状态 = 上游状态的纯函数。
///
/// 示例输出：「Hello, World! (counter = 0)」 → 调 counter.increment → 「Hello, World! (counter = 1)」
final Provider<String> greetingWithCounterProvider = Provider<String>(
  (ref) {
    final greeting = ref.watch(greetingProvider);
    final counter = ref.watch(counterStateNotifierProvider);
    return '$greeting (counter = $counter)';
  },
  name: 'greetingWithCounterProvider',
);
