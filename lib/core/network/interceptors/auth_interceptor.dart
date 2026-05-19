import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Access/refresh token 持久化抽象（T04.3）。
///
/// M05/T05.2（flutter_secure_storage）会提供真实实现，替换默认的 [InMemoryTokenStorage]。
abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> save({required String accessToken, required String refreshToken});
  Future<void> clear();
}

/// Token 刷新行为抽象。M19/T19.1 登录模块会提供真实实现（调 `/auth/refresh`）。
abstract class TokenRefresher {
  /// 返回新的 access + refresh 对；失败抛任意异常（[AuthInterceptor] 视作刷新失败）。
  Future<({String access, String refresh})> refresh(String currentRefreshToken);
}

/// 强制登出回调通道。M19 会注入路由跳转到登录页 + 清理本地数据。
abstract class AuthEvents {
  void onForcedLogout({Object? cause});
}

/// 内存版 [TokenStorage]，仅供测试 / 桌面端没有 secure storage 时手工注入。
///
/// **不**注册到 DI：M05/T05.2 完成后由 `SecureTokenStorage` 通过
/// `@LazySingleton(as: TokenStorage)` 提供生产实现。
class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage();

  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

/// T04.3 默认 [TokenRefresher] 占位实现。永远抛错，提示需要在 M19 替换。
@LazySingleton(as: TokenRefresher)
class StubTokenRefresher implements TokenRefresher {
  const StubTokenRefresher();

  @override
  Future<({String access, String refresh})> refresh(
    String currentRefreshToken,
  ) async {
    throw StateError(
      'TokenRefresher 未实现：请在 M19/T19.1 提供真实 refresh 端点的实现，'
      '并通过 @LazySingleton(as: TokenRefresher) 替换 StubTokenRefresher',
    );
  }
}

/// T04.3 默认 [AuthEvents] 占位实现。M19 会注入路由跳转。
@LazySingleton(as: AuthEvents)
class NoopAuthEvents implements AuthEvents {
  const NoopAuthEvents();

  @override
  void onForcedLogout({Object? cause}) {
    // 占位；M19 接入 router.go('/login') 与本地数据清理
  }
}

/// 鉴权拦截器（T04.3）。
///
/// 行为：
/// 1. **请求前**：从 [TokenStorage] 读 access token，注入 `Authorization: Bearer <token>`
/// 2. **401 响应**：暂停所有后续请求，调用 [TokenRefresher.refresh] 刷新 token
/// 3. **刷新成功**：用新 token 重发原请求，并继续处理排队中的其它 401
/// 4. **刷新失败**：清除 token、调用 [AuthEvents.onForcedLogout]、把错误透传
///
/// 注意：本拦截器**不是** `@lazySingleton`，由 [NetworkModule] 在构造 dio 时显式 new，
/// 因为它需要持有 dio 引用以便重发请求（避免 DI 循环依赖）。
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage storage,
    required TokenRefresher refresher,
    required AuthEvents events,
  }) : _storage = storage,
       _refresher = refresher,
       _events = events;

  final TokenStorage _storage;
  final TokenRefresher _refresher;
  final AuthEvents _events;

  /// 在 [NetworkModule.provideDio] 构造完 Dio 后由 setter 注入，
  /// 用于 token 刷新成功后重发原请求。
  Dio? dio;

  /// 当前正在进行的刷新会话；true=成功，false=失败。
  /// 用 [Completer] 而非 Future 直接返回，便于并发 401 共享同一次刷新。
  Completer<bool>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 允许显式跳过：在调 refresh 端点时不要再叠 token
    if (options.extra['skip_auth'] == true) {
      return handler.next(options);
    }
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    if (err.requestOptions.extra['retried_after_refresh'] == true) {
      // 刷新后重试仍 401，放弃
      _events.onForcedLogout(cause: err);
      await _storage.clear();
      return handler.next(err);
    }

    final bool refreshOk;
    if (_refreshCompleter != null) {
      // 已有刷新进行中，等同一结果
      refreshOk = await _refreshCompleter!.future;
    } else {
      // 启动新刷新会话
      final completer = _refreshCompleter = Completer<bool>();
      refreshOk = await _performRefreshSession();
      completer.complete(refreshOk);
      _refreshCompleter = null;
    }

    if (!refreshOk) {
      return handler.next(err);
    }
    return _retryWithNewToken(err, handler);
  }

  Future<bool> _performRefreshSession() async {
    try {
      await _doRefresh();
      return true;
    } catch (e) {
      _events.onForcedLogout(cause: e);
      await _storage.clear();
      return false;
    }
  }

  Future<void> _doRefresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token available');
    }
    final tokens = await _refresher.refresh(refreshToken);
    await _storage.save(
      accessToken: tokens.access,
      refreshToken: tokens.refresh,
    );
  }

  Future<void> _retryWithNewToken(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final dio = this.dio;
    if (dio == null) {
      return handler.next(err);
    }
    final newToken = await _storage.readAccessToken();
    if (newToken == null) {
      return handler.next(err);
    }
    final options = err.requestOptions;
    options.headers['Authorization'] = 'Bearer $newToken';
    options.extra['retried_after_refresh'] = true;
    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
