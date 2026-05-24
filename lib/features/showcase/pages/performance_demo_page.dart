import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/logger/startup_tracker.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/examples/performance/high_performance_list_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_image.dart';

/// M21 性能优化体系 demo：启动耗时埋点 + 高性能长列表 + 图片缓存优化。
class PerformanceDemoPage extends StatelessWidget {
  const PerformanceDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      moduleId: 'M21',
      title: '性能优化体系',
      children: <Widget>[
        DemoSection(
          title: '启动耗时埋点（T21.1）',
          description: 'StartupTracker 记录的各阶段耗时（仅通过 bootstrap '
              '启动的 main_dev/staging/prod 入口会采集）。',
          child: _StartupPhasesView(),
        ),
        DemoSection(
          title: '高性能长列表（T21.3）',
          description: 'ListView.builder + itemExtent 固定行高 + RepaintBoundary '
              '隔离，万级列表丝滑滚动。',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HighPerformanceListPage(),
                ),
              ),
              icon: const Icon(Icons.list_alt),
              label: const Text('打开 1 万项列表'),
            ),
          ),
        ),
        const DemoSection(
          title: '图片缓存优化（T21.4）',
          description: 'AppImage.thumbnail 按展示尺寸解码进内存（memCacheWidth），'
              '避免大图按原分辨率撑爆内存；缩略图与原图磁盘缓存分离。',
          child: _ThumbnailRow(),
        ),
      ],
    );
  }
}

class _StartupPhasesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tracker = StartupTracker.instance;
    final phases = tracker.phases;
    if (phases.isEmpty) {
      return const DemoResultRow('状态', '未采集（showcase 入口未走 bootstrap）');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final phase in phases)
          DemoResultRow(
            phase.name,
            '+${phase.delta.inMilliseconds}ms  '
                '(@${phase.sinceStart.inMilliseconds}ms)',
          ),
        if (tracker.firstFrameTime != null)
          DemoResultRow(
            '首帧',
            '${tracker.firstFrameTime!.inMilliseconds}ms',
          ),
      ],
    );
  }
}

class _ThumbnailRow extends StatelessWidget {
  const _ThumbnailRow();

  @override
  Widget build(BuildContext context) {
    // 占位 URL（无网络时显示占位/错误图，组件仍正常构建）。
    const url = 'https://picsum.photos/600';
    return Wrap(
      spacing: SpacingTokens.md,
      runSpacing: SpacingTokens.md,
      children: <Widget>[
        for (final size in <double>[64, 96, 128])
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppImage.thumbnail(url, size: size),
              const SizedBox(height: SpacingTokens.xs),
              Text('${size.toInt()}px'),
            ],
          ),
      ],
    );
  }
}
