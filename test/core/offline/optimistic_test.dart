import 'package:flutter_claude_app_v2/core/offline/optimistic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('runOptimistic (T25.3)', () {
    test('成功：先发乐观态，提交成功后保持', () async {
      final emitted = <bool>[];
      final result = await runOptimistic<bool>(
        previous: false,
        optimistic: true,
        emit: emitted.add,
        commit: () async {},
      );

      expect(emitted, <bool>[true]); // 只发了乐观态
      expect(result.committed, isTrue);
      expect(result.value, isTrue);
      expect(result.error, isNull);
    });

    test('失败：先发乐观态，提交失败后回滚到先前态', () async {
      final emitted = <bool>[];
      final result = await runOptimistic<bool>(
        previous: false,
        optimistic: true,
        emit: emitted.add,
        commit: () async => throw Exception('network'),
      );

      expect(emitted, <bool>[true, false]); // 乐观 → 回滚
      expect(result.committed, isFalse);
      expect(result.value, isFalse);
      expect(result.error, isA<Exception>());
    });

    test('乐观态先于网络完成被发射（UI 立即响应）', () async {
      final emitted = <int>[];
      final future = runOptimistic<int>(
        previous: 0,
        optimistic: 1,
        emit: emitted.add,
        commit: () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      // commit 尚未完成，乐观态应已发射
      expect(emitted, <int>[1]);
      await future;
      expect(emitted, <int>[1]); // 成功不再回滚
    });
  });
}
