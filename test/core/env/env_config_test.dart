import 'package:flutter_claude_app_v2/core/env/app_environment.dart';
import 'package:flutter_claude_app_v2/core/env/env_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvConfig.defaults (T15.1)', () {
    test('dev：日志开、上报关、dev 包名/地址', () {
      final c = EnvConfig.defaults(AppEnvironment.dev);
      expect(c.environment, AppEnvironment.dev);
      expect(c.appName, 'CCD Dev');
      expect(c.appId.endsWith('.dev'), isTrue);
      expect(c.apiBaseUrl, contains('dev-api'));
      expect(c.enableLogging, isTrue);
      expect(c.enableCrashReporting, isFalse);
    });

    test('staging：日志开、上报开', () {
      final c = EnvConfig.defaults(AppEnvironment.staging);
      expect(c.appId.endsWith('.staging'), isTrue);
      expect(c.enableLogging, isTrue);
      expect(c.enableCrashReporting, isTrue);
    });

    test('prod：日志关、上报开、无包名后缀', () {
      final c = EnvConfig.defaults(AppEnvironment.prod);
      expect(c.appName, 'CCD');
      expect(c.appId.endsWith('.dev'), isFalse);
      expect(c.appId.endsWith('.staging'), isFalse);
      expect(c.enableLogging, isFalse);
      expect(c.enableCrashReporting, isTrue);
    });
  });

  group('EnvConfig.resolve (T15.3)', () {
    test('无 dart-define 时等于默认值', () {
      // 测试进程未传 --dart-define，故 resolve 应回退到 defaults。
      for (final env in AppEnvironment.values) {
        expect(EnvConfig.resolve(env), EnvConfig.defaults(env));
      }
    });
  });

  group('EnvConfig 行为', () {
    test('copyWith 覆盖字段', () {
      final c = EnvConfig.defaults(AppEnvironment.dev)
          .copyWith(apiBaseUrl: 'https://x', enableCrashReporting: true);
      expect(c.apiBaseUrl, 'https://x');
      expect(c.enableCrashReporting, isTrue);
      expect(c.appName, 'CCD Dev'); // 未改的保留
    });

    test('== / hashCode 基于字段', () {
      expect(
        EnvConfig.defaults(AppEnvironment.prod),
        EnvConfig.defaults(AppEnvironment.prod),
      );
      expect(
        EnvConfig.defaults(AppEnvironment.dev) ==
            EnvConfig.defaults(AppEnvironment.prod),
        isFalse,
      );
    });

    test('hasSentryDsn 反映 DSN 是否配置', () {
      expect(EnvConfig.defaults(AppEnvironment.prod).hasSentryDsn, isFalse);
      final withDsn = EnvConfig.defaults(AppEnvironment.prod)
          .copyWith(sentryDsn: 'https://abc@sentry.io/1');
      expect(withDsn.hasSentryDsn, isTrue);
    });

    test('toString 对 DSN 脱敏', () {
      final withDsn = EnvConfig.defaults(AppEnvironment.prod)
          .copyWith(sentryDsn: 'https://secret@sentry.io/1');
      expect(withDsn.toString(), contains('***'));
      expect(withDsn.toString(), isNot(contains('secret')));
    });
  });

  group('envConfigProvider (T15.1)', () {
    test('默认值为 dev defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(envConfigProvider),
        EnvConfig.defaults(AppEnvironment.dev),
      );
    });

    test('可被 overrideWithValue 覆盖为指定环境', () {
      final prod = EnvConfig.resolve(AppEnvironment.prod);
      final container = ProviderContainer(
        overrides: <Override>[envConfigProvider.overrideWithValue(prod)],
      );
      addTearDown(container.dispose);
      expect(container.read(envConfigProvider).environment, AppEnvironment.prod);
    });
  });
}
