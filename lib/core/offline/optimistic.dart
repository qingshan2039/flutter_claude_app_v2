import 'package:flutter/foundation.dart';

/// 乐观更新结果（T25.3）。
@immutable
class OptimisticResult<T> {
  const OptimisticResult({
    required this.value,
    required this.committed,
    this.error,
  });

  /// 最终状态：提交成功为乐观值，回滚后为先前值。
  final T value;

  /// 是否提交成功（false 表示已回滚）。
  final bool committed;

  /// 失败原因（committed 为 true 时为 null）。
  final Object? error;
}

/// 乐观更新（T25.3）：**先更 UI，再发请求，失败回滚**。
///
/// 立即 [emit] 乐观状态 [optimistic]，随后执行 [commit]（网络请求）；commit 抛错
/// 则 [emit] 回 [previous]（回滚）并在结果中带上 error。
///
/// ```dart
/// final r = await runOptimistic<bool>(
///   previous: liked,
///   optimistic: !liked,
///   emit: (v) => setState(() => liked = v),
///   commit: () => api.setLiked(!liked),
/// );
/// if (!r.committed) showError(r.error);
/// ```
Future<OptimisticResult<T>> runOptimistic<T>({
  required T previous,
  required T optimistic,
  required void Function(T value) emit,
  required Future<void> Function() commit,
}) async {
  emit(optimistic); // 先更 UI
  try {
    await commit(); // 发请求
    return OptimisticResult<T>(value: optimistic, committed: true);
  } catch (error) {
    emit(previous); // 失败回滚
    return OptimisticResult<T>(
      value: previous,
      committed: false,
      error: error,
    );
  }
}
