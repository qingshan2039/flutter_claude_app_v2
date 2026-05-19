import 'dart:io';

import 'package:flutter_claude_app_v2/core/di/examples/eager_singleton_service.dart';
import 'package:flutter_claude_app_v2/core/di/examples/factory_service.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/utils/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/storage_test_setup.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await setupStorageMocks();
    await getIt.reset();
    await configureDependencies(environment: 'dev');
  });

  tearDown(() async {
    await getIt.reset();
    await tearDownStorageMocks(tempDir);
  });

  group('@singleton (eager)', () {
    test('两次解析返回同一实例', () {
      final a = getIt<EagerSingletonService>();
      final b = getIt<EagerSingletonService>();
      expect(identical(a, b), isTrue);
    });

    test('initializedAt 在 configure 时即被设置（eager 语义）', () async {
      final before = DateTime.now();
      // 重新 configure 一次，再立刻读 initializedAt
      await getIt.reset();
      await configureDependencies(environment: 'dev');
      final after = DateTime.now();

      final service = getIt<EagerSingletonService>();
      // initializedAt 应位于 configure 调用窗口之内
      expect(
        service.initializedAt.isAfter(before) ||
            service.initializedAt.isAtSameMomentAs(before),
        isTrue,
        reason: 'singleton 应在 configure 调用瞬间创建',
      );
      expect(
        service.initializedAt.isBefore(after) ||
            service.initializedAt.isAtSameMomentAs(after),
        isTrue,
      );
    });
  });

  group('@lazySingleton', () {
    test('两次解析返回同一实例', () {
      final a = getIt<AppInfo>();
      final b = getIt<AppInfo>();
      expect(identical(a, b), isTrue);
    });
  });

  group('@injectable (factory)', () {
    test('两次解析返回不同实例', () async {
      final a = getIt<FactoryService>();
      // 让两次创建之间至少跨过一次 DateTime tick
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final b = getIt<FactoryService>();

      expect(identical(a, b), isFalse);
      expect(
        b.createdAt.isAfter(a.createdAt) ||
            b.createdAt.isAtSameMomentAs(a.createdAt),
        isTrue,
      );
    });
  });
}
