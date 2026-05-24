import 'package:flutter_claude_app_v2/core/remote_config/default_remote_config.dart';
import 'package:flutter_claude_app_v2/core/remote_config/remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

class _FakeClient implements RemoteConfigClient {
  _FakeClient(this.data);
  Map<String, Object> data;
  int fetchCount = 0;
  @override
  Future<Map<String, Object>> fetch() async {
    fetchCount++;
    return data;
  }
}

void main() {
  group('DefaultRemoteConfig (T28.1)', () {
    test('无缓存无激活 → 返回默认值', () {
      final config = DefaultRemoteConfig(
        _FakeClient(const {}),
        InMemoryKeyValueStorage(),
      );
      expect(config.getString('welcome_title'), '欢迎'); // 默认
      expect(config.getBool('new_checkout_enabled'), isFalse);
      expect(config.getInt('max_upload_mb'), 20);
      expect(config.getString('unknown', defaultValue: 'fallback'), 'fallback');
    });

    test('fetchAndActivate 激活远程值并返回 changed', () async {
      final config = DefaultRemoteConfig(
        _FakeClient(const {'welcome_title': 'hi', 'max_upload_mb': 99}),
        InMemoryKeyValueStorage(),
      );
      final changed = await config.fetchAndActivate();
      expect(changed, isTrue);
      expect(config.getString('welcome_title'), 'hi');
      expect(config.getInt('max_upload_mb'), 99);
    });

    test('类型强转：num → int/double', () async {
      final config = DefaultRemoteConfig(
        _FakeClient(const {'ratio': 3.7, 'count': 5}),
        InMemoryKeyValueStorage(),
      );
      await config.fetchAndActivate();
      expect(config.getInt('ratio'), 3); // double → int 截断
      expect(config.getDouble('count'), 5.0); // int → double
    });

    test('getAll 合并默认值与激活值', () async {
      final config = DefaultRemoteConfig(
        _FakeClient(const {'welcome_title': 'hi'}),
        InMemoryKeyValueStorage(),
      );
      await config.fetchAndActivate();
      final all = config.getAll();
      expect(all['welcome_title'], 'hi'); // 激活覆盖
      expect(all['max_upload_mb'], 20); // 默认打底
    });
  });

  group('DefaultRemoteConfig 缓存与刷新 (T28.4)', () {
    test('fetchAndActivate 写入缓存，新实例无需联网即生效', () async {
      final storage = InMemoryKeyValueStorage();
      final first = DefaultRemoteConfig(
        _FakeClient(const {'welcome_title': 'cached!'}),
        storage,
      );
      await first.fetchAndActivate();

      // 新实例（不同 client）构造时加载缓存。
      final offlineClient = _FakeClient(const {});
      final second = DefaultRemoteConfig(offlineClient, storage);
      expect(second.getString('welcome_title'), 'cached!');
      expect(offlineClient.fetchCount, 0); // 未联网
    });

    test('相同内容再次激活返回 changed=false', () async {
      final client = _FakeClient(const {'welcome_title': 'same'});
      final config = DefaultRemoteConfig(client, InMemoryKeyValueStorage());
      await config.fetchAndActivate();
      final changedAgain = await config.fetchAndActivate();
      expect(changedAgain, isFalse);
    });
  });
}
