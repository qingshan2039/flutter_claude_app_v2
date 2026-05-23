import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 异步状态封装（T14.2）。
///
/// 把 Riverpod 的 [AsyncValue] 三态统一映射到状态组件，省去每个页面手写
/// `when(data/loading/error)` + 各自的 loading/error UI：
///
/// ```dart
/// final users = ref.watch(usersProvider);
/// return AsyncValueWidget<List<User>>(
///   value: users,
///   data: (list) => UserList(list),
///   onRetry: () => ref.invalidate(usersProvider),
/// );
/// ```
///
/// 细节：
/// - 默认 loading → [LoadingWidget]，error → [AppErrorView]（带重试）。
/// - [skeleton] 为 true 时 loading 用 [SkeletonLoader] 骨架屏。
/// - [onRefreshing] 为 true（默认）时，**有旧数据**的刷新中不盖 loading，直接展示
///   旧数据（`AsyncValue.isRefreshing`），避免刷新闪烁。
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
    this.skeleton = false,
    this.keepDataOnRefresh = true,
  });

  /// 要渲染的异步值。
  final AsyncValue<T> value;

  /// 有数据时的构建器。
  final Widget Function(T data) data;

  /// 自定义 loading（覆盖默认）。
  final Widget? loading;

  /// 自定义 error（覆盖默认）。
  final Widget Function(Object error, StackTrace stackTrace)? error;

  /// error 默认视图的重试回调。
  final VoidCallback? onRetry;

  /// loading 是否用骨架屏。
  final bool skeleton;

  /// 刷新中（已有旧数据）是否继续展示旧数据。
  final bool keepDataOnRefresh;

  Widget _defaultLoading() =>
      skeleton ? const SkeletonLoader() : const LoadingWidget.fullscreen();

  @override
  Widget build(BuildContext context) {
    // 刷新中且已有旧数据：展示旧数据，不闪 loading。
    if (keepDataOnRefresh && value.isRefreshing && value.hasValue) {
      return data(value.requireValue);
    }

    return value.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      data: data,
      loading: () => loading ?? _defaultLoading(),
      error: (e, st) =>
          error?.call(e, st) ??
          AppErrorView(message: e.toString(), onRetry: onRetry),
    );
  }
}
