import 'package:flutter_claude_app_v2/core/offline/sync_queue.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

PendingOperation _op(String id, {int retry = 0}) => PendingOperation(
  id: id,
  type: 'createPost',
  payload: <String, dynamic>{'text': id},
  createdAt: DateTime(2026, 5, 1),
  retryCount: retry,
);

void main() {
  late InMemoryKeyValueStorage kv;
  late SyncQueue queue;

  setUp(() {
    kv = InMemoryKeyValueStorage();
    queue = SyncQueue(kv);
  });

  group('SyncQueue 基础 (T25.2)', () {
    test('enqueue / all / length / remove / clear', () async {
      expect(queue.isEmpty, isTrue);
      await queue.enqueue(_op('a'));
      await queue.enqueue(_op('b'));
      expect(queue.length, 2);
      expect(queue.all().map((o) => o.id), <String>['a', 'b']);

      await queue.remove('a');
      expect(queue.all().map((o) => o.id), <String>['b']);

      await queue.clear();
      expect(queue.isEmpty, isTrue);
    });

    test('持久化：另一个实例可见同一队列', () async {
      await queue.enqueue(_op('a'));
      final reopened = SyncQueue(kv);
      expect(reopened.length, 1);
      expect(reopened.all().first.payload['text'], 'a');
    });
  });

  group('SyncQueue.flush 上线同步 (T25.2)', () {
    test('全部成功 → 队列清空', () async {
      await queue.enqueue(_op('a'));
      await queue.enqueue(_op('b'));
      final report = await queue.flush((_) async => true);
      expect(report.synced, 2);
      expect(report.failed, 0);
      expect(queue.isEmpty, isTrue);
    });

    test('部分失败 → 保留失败项并 retry+1', () async {
      await queue.enqueue(_op('ok'));
      await queue.enqueue(_op('bad'));
      final report = await queue.flush((op) async => op.id == 'ok');
      expect(report.synced, 1);
      expect(report.failed, 1);
      expect(queue.all().map((o) => o.id), <String>['bad']);
      expect(queue.all().first.retryCount, 1);
    });

    test('handler 抛异常 → 计为失败并保留', () async {
      await queue.enqueue(_op('x'));
      final report = await queue.flush((_) async => throw Exception('boom'));
      expect(report.failed, 1);
      expect(queue.length, 1);
      expect(queue.all().first.retryCount, 1);
    });
  });
}
