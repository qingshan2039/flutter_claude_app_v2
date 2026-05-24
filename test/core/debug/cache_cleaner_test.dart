import 'package:flutter_claude_app_v2/core/debug/cache_cleaner.dart';
import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheCleaner (T29.5)', () {
    late InMemoryKeyValueStorage kv;
    late InMemorySecureStorage secure;
    late CacheCleaner cleaner;

    setUp(() {
      kv = InMemoryKeyValueStorage();
      secure = InMemorySecureStorage();
      cleaner = CacheCleaner(kv, secure);
    });

    test('clearKeyValue 清空键值存储', () async {
      await kv.setString('a', '1');
      await cleaner.clearKeyValue();
      expect(kv.getKeys(), isEmpty);
    });

    test('clearSecure 清空安全存储', () async {
      await secure.write('token', 'abc');
      await cleaner.clearSecure();
      expect(await secure.readAll(), isEmpty);
    });

    test('clearAll 清 KV + secure', () async {
      await kv.setString('a', '1');
      await secure.write('token', 'abc');
      await cleaner.clearAll();
      expect(kv.getKeys(), isEmpty);
      expect(await secure.readAll(), isEmpty);
    });

    test('clearImageCache 不抛异常', () {
      cleaner.clearImageCache();
    });
  });
}
