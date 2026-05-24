import 'package:flutter_claude_app_v2/core/privacy/consent_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

/// T24.1：隐私同意存储。
void main() {
  group('ConsentStore (T24.1)', () {
    late ConsentStore store;

    setUp(() => store = ConsentStore(InMemoryKeyValueStorage()));

    test('从未同意 → needsConsent 为 true', () {
      expect(store.needsConsent('1.0.0'), isTrue);
      expect(store.hasAgreed('1.0.0'), isFalse);
      expect(store.agreedVersion(), isNull);
    });

    test('agree 记录版本与时间', () async {
      final at = DateTime(2026, 5, 24, 10);
      await store.agree('1.0.0', at: at);

      expect(store.hasAgreed('1.0.0'), isTrue);
      expect(store.needsConsent('1.0.0'), isFalse);
      expect(store.agreedVersion(), '1.0.0');
      expect(store.agreedAt(), at);
    });

    test('政策升版本 → 需重新同意', () async {
      await store.agree('1.0.0');
      expect(store.needsConsent('2.0.0'), isTrue);
      expect(store.hasAgreed('2.0.0'), isFalse);
    });

    test('revoke 清除同意', () async {
      await store.agree('1.0.0');
      await store.revoke();
      expect(store.needsConsent('1.0.0'), isTrue);
      expect(store.agreedVersion(), isNull);
    });
  });
}
