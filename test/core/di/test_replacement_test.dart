import 'package:flutter_claude_app_v2/core/di/examples/environment_aware_service.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

/// 测试专用的 [ApiClient] 替身：无副作用、返回固定值，方便断言。
class FakeApiClient implements ApiClient {
  FakeApiClient(this._payload);
  final String _payload;

  int fetchCallCount = 0;

  @override
  String get name => 'FakeApiClient';

  @override
  Future<String> fetch() async {
    fetchCallCount++;
    return _payload;
  }
}

void main() {
  tearDown(() async => getIt.reset());

  group('测试场景：手动替换依赖', () {
    test('configure 前手动注册 fake，跳过 injectable', () async {
      await getIt.reset();
      getIt.registerLazySingleton<ApiClient>(() => FakeApiClient('payload-A'));

      final client = getIt<ApiClient>();
      expect(client, isA<FakeApiClient>());
      expect(await client.fetch(), 'payload-A');
    });

    test('configure 之后通过 unregister + register 替换', () async {
      await getIt.reset();
      await configureDependencies(environment: 'dev');
      expect(getIt<ApiClient>(), isA<MockApiClient>());

      await getIt.unregister<ApiClient>();
      getIt.registerLazySingleton<ApiClient>(() => FakeApiClient('payload-B'));

      final client = getIt<ApiClient>();
      expect(client, isA<FakeApiClient>());
      expect(await client.fetch(), 'payload-B');
    });

    test('使用 fake 替身验证业务逻辑（调用次数）', () async {
      await getIt.reset();
      final fake = FakeApiClient('counted');
      getIt.registerSingleton<ApiClient>(fake);

      // 业务代码通过 DI 拿到的就是同一个 fake
      final client = getIt<ApiClient>();
      await client.fetch();
      await client.fetch();
      await client.fetch();

      expect(fake.fetchCallCount, 3);
    });

    test('environment="test" 不注册 dev/prod 任一实现，便于纯测试栈', () async {
      await getIt.reset();
      await configureDependencies(environment: 'test');

      // injectable 没注册 ApiClient → 必须手动提供 fake
      expect(getIt.isRegistered<ApiClient>(), isFalse);
      getIt.registerSingleton<ApiClient>(FakeApiClient('test-stack'));
      expect(getIt<ApiClient>(), isA<FakeApiClient>());
    });
  });
}
