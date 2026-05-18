import 'package:flutter_claude_app_v2/core/di/examples/environment_aware_service.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() async => getIt.reset());

  group('按环境注册（@dev / @prod / @test）', () {
    test('environment="dev" → ApiClient 解析为 MockApiClient', () async {
      await getIt.reset();
      await configureDependencies(environment: 'dev');

      final client = getIt<ApiClient>();
      expect(client, isA<MockApiClient>());
      expect(client.name, 'MockApiClient');
      expect(await client.fetch(), 'mock-data');
    });

    test('environment="prod" → ApiClient 解析为 RealApiClient', () async {
      await getIt.reset();
      await configureDependencies(environment: 'prod');

      final client = getIt<ApiClient>();
      expect(client, isA<RealApiClient>());
      expect(client.name, 'RealApiClient');
      expect(await client.fetch(), 'real-data');
    });

    test('environment=null → ApiClient 完全未注册', () async {
      await getIt.reset();
      await configureDependencies();

      expect(getIt.isRegistered<ApiClient>(), isFalse);
    });

    test('environment="test" → 没有匹配实现时 ApiClient 未注册', () async {
      await getIt.reset();
      await configureDependencies(environment: 'test');

      expect(getIt.isRegistered<ApiClient>(), isFalse);
    });

    test('切换 environment 后旧实例失效', () async {
      // dev → 拿到 MockApiClient
      await getIt.reset();
      await configureDependencies(environment: 'dev');
      expect(getIt<ApiClient>(), isA<MockApiClient>());

      // 切到 prod → 拿到 RealApiClient
      await getIt.reset();
      await configureDependencies(environment: 'prod');
      expect(getIt<ApiClient>(), isA<RealApiClient>());
    });
  });
}
