import 'package:flutter_claude_app_v2/core/network/cancel_token_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CancelTokenManager manager;

  setUp(() => manager = CancelTokenManager());

  group('acquire / cancel', () {
    test('acquire 为 key 创建未取消 token', () {
      final token = manager.acquire('page1');
      expect(token.isCancelled, isFalse);
      expect(manager.hasToken('page1'), isTrue);
      expect(manager.activeCount, 1);
    });

    test('cancel 后 token 被取消并从 map 移除', () {
      final token = manager.acquire('page1');
      manager.cancel('page1', reason: 'navigated');
      expect(token.isCancelled, isTrue);
      expect(manager.hasToken('page1'), isFalse);
      expect(manager.activeCount, 0);
    });

    test('同 key 再次 acquire 自动取消旧 token', () {
      final t1 = manager.acquire('page1');
      final t2 = manager.acquire('page1', replacedReason: 'rebuild');
      expect(t1.isCancelled, isTrue);
      expect(t2.isCancelled, isFalse);
      expect(manager.hasToken('page1'), isTrue);
    });

    test('不存在的 key cancel 是无操作', () {
      expect(() => manager.cancel('ghost'), returnsNormally);
    });
  });

  group('cancelAll', () {
    test('cancelAll 取消所有并清空 map', () {
      final t1 = manager.acquire('a');
      final t2 = manager.acquire('b');
      final t3 = manager.acquire('c');

      manager.cancelAll(reason: 'logout');

      expect(t1.isCancelled, isTrue);
      expect(t2.isCancelled, isTrue);
      expect(t3.isCancelled, isTrue);
      expect(manager.activeCount, 0);
      expect(manager.hasToken('a'), isFalse);
    });

    test('cancelAll 之后再 acquire 工作正常', () {
      manager.acquire('a');
      manager.cancelAll();
      final newToken = manager.acquire('a');
      expect(newToken.isCancelled, isFalse);
      expect(manager.activeCount, 1);
    });
  });
}
