import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// 取消令牌管理器（T04.7）。
///
/// 用途：把 [CancelToken] 与某个 key（页面、Provider、业务流程）绑定，
/// 在 key 销毁时一键取消所有未完成的请求。
///
/// 与 Riverpod autoDispose 联动（M06 完成后使用）：
/// ```dart
/// final fooProvider = FutureProvider.autoDispose<Foo>((ref) async {
///   final manager = getIt<CancelTokenManager>();
///   final token = manager.acquire(ref);
///   ref.onDispose(() => manager.cancel(ref, 'provider disposed'));
///   return repo.loadFoo(cancelToken: token);
/// });
/// ```
///
/// 同一 key 多次 [acquire]：前一个 token 会被自动取消，避免并发请求争抢同一 UI 状态。
@lazySingleton
class CancelTokenManager {
  CancelTokenManager();

  final Map<Object, CancelToken> _tokens = <Object, CancelToken>{};

  /// 为 [key] 分配新的 [CancelToken]，并取消该 key 上一个已有 token（如有）。
  CancelToken acquire(Object key, {String? replacedReason}) {
    cancel(key, reason: replacedReason ?? 'Replaced by new acquire');
    final token = CancelToken();
    _tokens[key] = token;
    return token;
  }

  /// 取消并移除 [key] 关联的 token；若 key 不存在则无操作。
  void cancel(Object key, {String? reason}) {
    final token = _tokens.remove(key);
    if (token != null && !token.isCancelled) {
      token.cancel(reason ?? 'Cancelled by manager');
    }
  }

  /// 批量取消所有 token（例如用户登出时清空）。
  void cancelAll({String? reason}) {
    final tokens = _tokens.values.toList();
    _tokens.clear();
    for (final token in tokens) {
      if (!token.isCancelled) {
        token.cancel(reason ?? 'Cancel all');
      }
    }
  }

  /// 当前活跃 token 数量（不包含已取消的）。
  int get activeCount =>
      _tokens.values.where((t) => !t.isCancelled).length;

  /// 测试 / 调试用：查看某个 key 是否有 token 在册。
  bool hasToken(Object key) => _tokens.containsKey(key);
}
