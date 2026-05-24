import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/remote_config/kill_switch.dart';
import 'package:flutter_claude_app_v2/core/remote_config/kill_switch_gate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/fake_remote_config.dart';

void main() {
  group('KillSwitchGate (T28.3)', () {
    testWidgets('未激活 → 显示 child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KillSwitchGate(
            killSwitch: KillSwitch(FakeRemoteConfig()),
            child: const Text('正常内容'),
          ),
        ),
      );
      expect(find.text('正常内容'), findsOneWidget);
      expect(find.text('服务暂时不可用'), findsNothing);
    });

    testWidgets('激活 → 显示强制下线页，隐藏 child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KillSwitchGate(
            killSwitch: KillSwitch(
              FakeRemoteConfig(const {
                'app_kill_switch': true,
                'app_kill_message': '系统升级中',
              }),
            ),
            child: const Text('正常内容'),
          ),
        ),
      );
      expect(find.text('服务暂时不可用'), findsOneWidget);
      expect(find.text('系统升级中'), findsOneWidget);
      expect(find.text('正常内容'), findsNothing);
    });

    testWidgets('active 覆盖 + onRetry 重试按钮', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: KillSwitchGate(
            active: true,
            message: '预览下线',
            onRetry: () => retried++,
            child: const Text('正常内容'),
          ),
        ),
      );
      expect(find.text('预览下线'), findsOneWidget);
      await tester.tap(find.text('重试'));
      expect(retried, 1);
    });
  });
}
