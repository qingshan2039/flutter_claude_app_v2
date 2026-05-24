import 'package:flutter_claude_app_v2/core/debug/debug_log_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugLogStore (T29.3)', () {
    test('add 记录并保序', () {
      final store = DebugLogStore();
      store
        ..add(DebugLogLevel.info, 'a')
        ..add(DebugLogLevel.error, 'b');
      expect(store.records.map((r) => r.message), <String>['a', 'b']);
    });

    test('环形缓冲：超出 capacity 丢弃最旧', () {
      final store = DebugLogStore()..capacity = 2;
      store
        ..add(DebugLogLevel.info, '1')
        ..add(DebugLogLevel.info, '2')
        ..add(DebugLogLevel.info, '3');
      expect(store.records.map((r) => r.message), <String>['2', '3']);
    });

    test('filter 按最低级别', () {
      final store = DebugLogStore()
        ..add(DebugLogLevel.debug, 'd')
        ..add(DebugLogLevel.warning, 'w')
        ..add(DebugLogLevel.error, 'e');
      final warnUp = store.filter(minLevel: DebugLogLevel.warning);
      expect(warnUp.map((r) => r.message), <String>['w', 'e']);
    });

    test('filter 按关键词（不区分大小写）', () {
      final store = DebugLogStore()
        ..add(DebugLogLevel.info, 'Login success')
        ..add(DebugLogLevel.info, 'logout');
      expect(
        store.filter(query: 'LOGIN').map((r) => r.message),
        <String>['Login success'],
      );
    });

    test('exportAsText 含级别与消息', () {
      final store = DebugLogStore()..add(DebugLogLevel.error, 'boom');
      final text = store.exportAsText();
      expect(text, contains('ERROR'));
      expect(text, contains('boom'));
    });

    test('clear 清空', () {
      final store = DebugLogStore()..add(DebugLogLevel.info, 'x');
      store.clear();
      expect(store.records, isEmpty);
    });
  });
}
