import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemorySecureStorage', () {
    late SecureStorage storage;

    setUp(() {
      storage = InMemorySecureStorage();
    });

    test('write 后 read 返回相同值', () async {
      await storage.write('k', 'v');
      expect(await storage.read('k'), 'v');
    });

    test('未写入的 key read 返回 null', () async {
      expect(await storage.read('missing'), isNull);
    });

    test('delete 移除 key', () async {
      await storage.write('k', 'v');
      await storage.delete('k');
      expect(await storage.read('k'), isNull);
      expect(await storage.containsKey('k'), isFalse);
    });

    test('deleteAll 清空全部', () async {
      await storage.write('a', '1');
      await storage.write('b', '2');
      await storage.deleteAll();
      expect((await storage.readAll()).isEmpty, isTrue);
    });

    test('containsKey 检测存在性', () async {
      expect(await storage.containsKey('a'), isFalse);
      await storage.write('a', 'x');
      expect(await storage.containsKey('a'), isTrue);
    });

    test('readAll 返回快照不共享底层 map', () async {
      await storage.write('a', '1');
      final snap = await storage.readAll();
      snap['b'] = 'mutated';
      expect(await storage.read('b'), isNull);   // 不应污染存储
    });
  });
}
