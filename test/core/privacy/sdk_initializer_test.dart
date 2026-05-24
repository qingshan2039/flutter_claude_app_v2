import 'package:flutter_claude_app_v2/core/privacy/sdk_initializer.dart';
import 'package:flutter_test/flutter_test.dart';

/// T24.2：SDK 初始化分级。
void main() {
  group('SdkInitializer (T24.2)', () {
    late SdkInitializer initializer;
    late List<String> ran;

    SdkComponent comp(String name, SdkTier tier) => SdkComponent(
      name: name,
      tier: tier,
      init: () async => ran.add(name),
    );

    setUp(() {
      ran = <String>[];
      initializer = SdkInitializer()
        ..register(comp('crash', SdkTier.essential))
        ..register(comp('storage', SdkTier.essential))
        ..register(comp('analytics', SdkTier.optional))
        ..register(comp('ads', SdkTier.optional));
    });

    test('未同意：只初始化必要 SDK', () async {
      final initialized = await initializer.initialize(consentGranted: false);
      expect(initialized, <String>['crash', 'storage']);
      expect(ran, <String>['crash', 'storage']);
      expect(initializer.initialized, <String>{'crash', 'storage'});
    });

    test('同意后：补充初始化可选 SDK（不重复必要）', () async {
      await initializer.initialize(consentGranted: false);
      final more = await initializer.initialize(consentGranted: true);
      expect(more, <String>['analytics', 'ads']);
      expect(ran, <String>['crash', 'storage', 'analytics', 'ads']);
    });

    test('幂等：重复 initialize 不再重复执行', () async {
      await initializer.initialize(consentGranted: true);
      final again = await initializer.initialize(consentGranted: true);
      expect(again, isEmpty);
      expect(ran, <String>['crash', 'storage', 'analytics', 'ads']);
    });

    test('一次性同意：直接初始化全部', () async {
      final initialized = await initializer.initialize(consentGranted: true);
      expect(initialized, <String>['crash', 'storage', 'analytics', 'ads']);
    });
  });
}
