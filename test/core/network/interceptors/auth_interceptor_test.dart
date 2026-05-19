import 'package:dio/dio.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_mock_adapter.dart';

class _FakeStorage implements TokenStorage {
  _FakeStorage({this.access, this.refresh});
  String? access;
  String? refresh;
  int clearCount = 0;
  int saveCount = 0;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
    saveCount++;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    clearCount++;
  }
}

class _FakeRefresher implements TokenRefresher {
  _FakeRefresher({this.shouldFail = false});
  bool shouldFail;
  int callCount = 0;

  @override
  Future<({String access, String refresh})> refresh(
    String currentRefreshToken,
  ) async {
    callCount++;
    if (shouldFail) throw Exception('refresh failed');
    return (access: 'new-access', refresh: 'new-refresh');
  }
}

class _FakeEvents implements AuthEvents {
  int forcedLogoutCount = 0;
  Object? lastCause;

  @override
  void onForcedLogout({Object? cause}) {
    forcedLogoutCount++;
    lastCause = cause;
  }
}

void main() {
  group('AuthInterceptor.onRequest', () {
    test('有 token 时注入 Authorization 头', () async {
      final storage = _FakeStorage(access: 'abc123', refresh: 'r1');
      final interceptor = AuthInterceptor(
        storage: storage,
        refresher: _FakeRefresher(),
        events: _FakeEvents(),
      );

      final adapter = MockAdapter((options, idx) => jsonResponse(200, {'ok': true}));
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);

      await dio.get<dynamic>('/foo');
      expect(adapter.requests.single.headers['Authorization'], 'Bearer abc123');
    });

    test('无 token 时不注入', () async {
      final storage = _FakeStorage();
      final interceptor = AuthInterceptor(
        storage: storage,
        refresher: _FakeRefresher(),
        events: _FakeEvents(),
      );

      final adapter = MockAdapter((options, idx) => jsonResponse(200, {'ok': true}));
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);

      await dio.get<dynamic>('/foo');
      expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
    });

    test('skip_auth 标记跳过 token 注入', () async {
      final storage = _FakeStorage(access: 'abc');
      final interceptor = AuthInterceptor(
        storage: storage,
        refresher: _FakeRefresher(),
        events: _FakeEvents(),
      );

      final adapter = MockAdapter((options, idx) => jsonResponse(200, {}));
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);

      await dio.get<dynamic>(
        '/refresh',
        options: Options(extra: <String, dynamic>{'skip_auth': true}),
      );
      expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('AuthInterceptor.onError 401 处理', () {
    test('401 → refresh 成功 → 重试得到 200', () async {
      final storage = _FakeStorage(access: 'old', refresh: 'r1');
      final refresher = _FakeRefresher();
      final events = _FakeEvents();
      final interceptor = AuthInterceptor(
        storage: storage,
        refresher: refresher,
        events: events,
      );

      final adapter = MockAdapter((options, callIndex) {
        if (callIndex == 0) return jsonResponse(401, {'err': 'unauth'});
        return jsonResponse(200, {'ok': true});
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);
      interceptor.dio = dio;

      final response = await dio.get<dynamic>('/foo');

      expect(response.statusCode, 200);
      expect(refresher.callCount, 1);
      expect(storage.access, 'new-access');
      expect(adapter.callCount, 2);
      // 重试时携带新 token
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-access',
      );
      expect(events.forcedLogoutCount, 0);
    });

    test('refresh 失败 → onForcedLogout + clear', () async {
      final storage = _FakeStorage(access: 'old', refresh: 'r1');
      final refresher = _FakeRefresher(shouldFail: true);
      final events = _FakeEvents();
      final interceptor = AuthInterceptor(
        storage: storage,
        refresher: refresher,
        events: events,
      );

      final adapter = MockAdapter((options, idx) => jsonResponse(401, {'err': 'x'}));
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);
      interceptor.dio = dio;

      await expectLater(
        dio.get<dynamic>('/foo'),
        throwsA(isA<DioException>()),
      );

      expect(events.forcedLogoutCount, 1);
      expect(storage.clearCount, 1);
      expect(storage.access, isNull);
    });

    test('非 401 错误透传（不触发 refresh）', () async {
      final storage = _FakeStorage(access: 'a', refresh: 'r');
      final refresher = _FakeRefresher();
      final events = _FakeEvents();
      final interceptor = AuthInterceptor(
        storage: storage,
        refresher: refresher,
        events: events,
      );

      final adapter = MockAdapter((options, idx) => jsonResponse(500, {'err': 'srv'}));
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);
      interceptor.dio = dio;

      await expectLater(
        dio.get<dynamic>('/foo'),
        throwsA(isA<DioException>()),
      );
      expect(refresher.callCount, 0);
      expect(events.forcedLogoutCount, 0);
    });
  });
}
