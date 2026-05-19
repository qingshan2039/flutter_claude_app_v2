import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 同步可变状态的 [StateNotifier] / [StateNotifierProvider] 示例（T06.2）。
///
/// **注**：Riverpod 2.x 引入了 [Notifier] 作为 [StateNotifier] 的现代替代。
/// 两者都能满足 spec 要求的「StateNotifier 示例」；本文件用 StateNotifier 以贴近
/// spec 命名，[Notifier] 版本见 `counter_notifier.dart` 中可选示例。
///
/// 适合场景：
/// - 计数器、表单字段、本地 UI flag 等可变同步状态
/// - 状态变更可被 [ProviderObserver] 观察（T06.3 链路示例）
class CounterStateNotifier extends StateNotifier<int> {
  CounterStateNotifier({int initial = 0}) : super(initial);

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final StateNotifierProvider<CounterStateNotifier, int> counterStateNotifierProvider =
    StateNotifierProvider<CounterStateNotifier, int>(
      (ref) => CounterStateNotifier(),
      name: 'counterStateNotifierProvider',
    );
