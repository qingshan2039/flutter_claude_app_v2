import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    storage = SharedPreferencesStorage(prefs);
  });

  group('String', () {
    test('set / get 往返一致', () async {
      await storage.setString('k', 'hello');
      expect(storage.getString('k'), 'hello');
    });

    test('未设置时返回 null', () {
      expect(storage.getString('missing'), isNull);
    });
  });

  group('int / bool / double / List<String>', () {
    test('int', () async {
      await storage.setInt('count', 42);
      expect(storage.getInt('count'), 42);
    });

    test('bool', () async {
      await storage.setBool('flag', true);
      expect(storage.getBool('flag'), isTrue);
    });

    test('double', () async {
      await storage.setDouble('ratio', 1.5);
      expect(storage.getDouble('ratio'), 1.5);
    });

    test('List<String>', () async {
      await storage.setStringList('tags', <String>['a', 'b']);
      expect(storage.getStringList('tags'), <String>['a', 'b']);
    });
  });

  group('管理操作', () {
    test('remove 移除指定 key', () async {
      await storage.setString('k', 'v');
      expect(storage.containsKey('k'), isTrue);
      await storage.remove('k');
      expect(storage.containsKey('k'), isFalse);
      expect(storage.getString('k'), isNull);
    });

    test('clear 清空所有键', () async {
      await storage.setString('a', '1');
      await storage.setInt('b', 2);
      await storage.clear();
      expect(storage.getKeys(), isEmpty);
    });

    test('containsKey 检测 key 存在性', () async {
      expect(storage.containsKey('x'), isFalse);
      await storage.setString('x', 'value');
      expect(storage.containsKey('x'), isTrue);
    });

    test('getKeys 返回当前所有键', () async {
      await storage.setString('a', '1');
      await storage.setString('b', '2');
      expect(storage.getKeys(), containsAll(<String>['a', 'b']));
    });
  });
}
