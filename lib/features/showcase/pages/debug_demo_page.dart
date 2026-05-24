import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/debug/debug_entry.dart';
import 'package:flutter_claude_app_v2/core/debug/debug_log_store.dart';
import 'package:flutter_claude_app_v2/core/debug/network_inspector.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/debug/presentation/pages/debug_panel_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M29 内置 Debug 面板 demo：长按入口打开面板 + 注入示例数据。
class DebugDemoPage extends StatelessWidget {
  const DebugDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoScaffold(
      moduleId: 'M29',
      title: '内置 Debug 面板',
      children: <Widget>[
        DemoSection(
          title: 'Debug 入口（T29.1）',
          description: '长按下方 LOGO 打开 Debug 面板（仅 dev/staging 启用；生产禁用）。',
          child: Center(
            child: DebugEntry(
              enabled: true,
              onTrigger: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const DebugPanelPage()),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.bug_report,
                  size: 56,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        DemoSection(
          title: '注入示例数据',
          description: '注入后打开面板可在「日志 / 网络」Tab 看到内容。',
          child: Wrap(
            spacing: SpacingTokens.sm,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: _injectLogs,
                icon: const Icon(Icons.article_outlined),
                label: const Text('注入示例日志'),
              ),
              FilledButton.tonalIcon(
                onPressed: _injectNetwork,
                icon: const Icon(Icons.swap_vert),
                label: const Text('注入示例网络'),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '面板能力（T29.2–T29.6）',
          description: '设备信息 / 环境切换(BaseUrl) / 日志查看(过滤·搜索·导出) / '
              '网络抓包 / 一键缓存清理。',
          child: Text('长按上方 LOGO 进入面板逐项体验。'),
        ),
      ],
    );
  }

  void _injectLogs() {
    final store = getIt<DebugLogStore>();
    const levels = DebugLogLevel.values;
    final rnd = Random();
    for (var i = 0; i < 8; i++) {
      store.add(levels[rnd.nextInt(levels.length)], '示例日志事件 #$i');
    }
  }

  void _injectNetwork() {
    final inspector = getIt<NetworkInspector>();
    for (var i = 0; i < 5; i++) {
      inspector.add(
        NetworkRecord(
          method: i.isEven ? 'GET' : 'POST',
          url: 'https://api.example.com/resource/$i',
          time: DateTime.now(),
          statusCode: i == 3 ? 500 : 200,
          durationMs: 50 + i * 30,
        ),
      );
    }
  }
}
