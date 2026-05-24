import 'package:flutter_claude_app_v2/core/remote_config/kill_switch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/fake_remote_config.dart';

void main() {
  group('KillSwitch (T28.3)', () {
    test('读取 app_kill_switch / app_kill_message', () {
      final ks = KillSwitch(
        FakeRemoteConfig(const {
          'app_kill_switch': true,
          'app_kill_message': '紧急维护中',
        }),
      );
      expect(ks.isActive, isTrue);
      expect(ks.message, '紧急维护中');
    });

    test('默认未激活 + 兜底文案', () {
      final ks = KillSwitch(FakeRemoteConfig());
      expect(ks.isActive, isFalse);
      expect(ks.message, '服务暂不可用，请稍后再试');
    });
  });
}
