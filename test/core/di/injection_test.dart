import 'dart:io';

import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/utils/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/storage_test_setup.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await setupStorageMocks();
    await getIt.reset();
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
    await tearDownStorageMocks(tempDir);
  });

  group('configureDependencies()', () {
    test('注册成功后 AppInfo 可解析', () {
      expect(getIt.isRegistered<AppInfo>(), isTrue);
      final info = getIt<AppInfo>();
      expect(info, isA<AppInfo>());
      expect(info.name, 'flutter_claude_app_v2');
      expect(info.version, '1.0.0+1');
    });

    test('lazySingleton 两次解析返回同一实例', () {
      final a = getIt<AppInfo>();
      final b = getIt<AppInfo>();
      expect(identical(a, b), isTrue);
    });

    test('reset 后再次 configure，得到新的实例', () async {
      final first = getIt<AppInfo>();
      await getIt.reset();
      await configureDependencies();
      final second = getIt<AppInfo>();
      expect(identical(first, second), isFalse);
      expect(second.name, 'flutter_claude_app_v2');
    });

    test('未注册的类型解析抛 StateError', () async {
      await getIt.reset();
      expect(() => getIt<AppInfo>(), throwsStateError);
    });
  });
}
