import 'package:flutter_claude_app_v2/core/debug/debug_overrides.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

void main() {
  group('DebugOverrides (T29.2)', () {
    test('默认无覆盖 → effectiveBaseUrl 用 fallback', () {
      final overrides = DebugOverrides(InMemoryKeyValueStorage());
      expect(overrides.baseUrlOverride, isNull);
      expect(overrides.effectiveBaseUrl('https://prod'), 'https://prod');
    });

    test('设置覆盖 → effectiveBaseUrl 用覆盖值', () async {
      final overrides = DebugOverrides(InMemoryKeyValueStorage());
      await overrides.setBaseUrl('https://staging');
      expect(overrides.baseUrlOverride, 'https://staging');
      expect(overrides.effectiveBaseUrl('https://prod'), 'https://staging');
    });

    test('清除覆盖 → 回到 fallback', () async {
      final overrides = DebugOverrides(InMemoryKeyValueStorage());
      await overrides.setBaseUrl('https://staging');
      await overrides.clearBaseUrl();
      expect(overrides.baseUrlOverride, isNull);
      expect(overrides.effectiveBaseUrl('https://prod'), 'https://prod');
    });

    test('持久化：新实例读到同一覆盖', () async {
      final kv = InMemoryKeyValueStorage();
      await DebugOverrides(kv).setBaseUrl('https://x');
      expect(DebugOverrides(kv).baseUrlOverride, 'https://x');
    });
  });
}
