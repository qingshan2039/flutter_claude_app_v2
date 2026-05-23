import 'package:flutter_claude_app_v2/core/env/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment', () {
    test('injectableName 与 name 一致', () {
      expect(AppEnvironment.dev.injectableName, 'dev');
      expect(AppEnvironment.staging.injectableName, 'staging');
      expect(AppEnvironment.prod.injectableName, 'prod');
    });

    test('isDev / isStaging / isProd', () {
      expect(AppEnvironment.dev.isDev, isTrue);
      expect(AppEnvironment.dev.isProd, isFalse);
      expect(AppEnvironment.prod.isProd, isTrue);
      expect(AppEnvironment.staging.isStaging, isTrue);
    });

    test('isReleaseLike：staging + prod 为 true，dev 为 false', () {
      expect(AppEnvironment.dev.isReleaseLike, isFalse);
      expect(AppEnvironment.staging.isReleaseLike, isTrue);
      expect(AppEnvironment.prod.isReleaseLike, isTrue);
    });

    test('三个环境值齐全', () {
      expect(AppEnvironment.values.length, 3);
    });
  });
}
