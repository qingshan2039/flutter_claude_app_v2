import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 高性能长列表示例（T21.3）。
///
/// 演示长列表（万级）的三个关键优化：
/// 1. **`ListView.builder`**：按需构建可见项，而非一次性建好全部。
/// 2. **`itemExtent`（固定行高）**：跳过逐项布局测量，滚动定位 O(1)；长列表性能
///    收益最大。若行高不定但有「典型项」，可改用 `prototypeItem`。
/// 3. **`RepaintBoundary` + const 行**：把每行隔离成独立图层，滚动时相邻行不重绘；
///    行内容尽量 const，减少 rebuild。
///
/// 对照实验：把 [useItemExtent] 关掉（仍是 builder，但无固定行高），在 DevTools
/// Performance 里能看到滚动时多出逐项布局开销。
class HighPerformanceListPage extends StatelessWidget {
  const HighPerformanceListPage({
    super.key,
    this.itemCount = 10000,
    this.useItemExtent = true,
  });

  /// 列表项数量（默认 1 万，演示长列表）。
  final int itemCount;

  /// 是否启用固定行高优化（默认开）。
  final bool useItemExtent;

  static const double _rowHeight = 72;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('高性能长列表 · $itemCount 项'),
      ),
      body: ListView.builder(
        // 固定行高：长列表的核心优化（可空时回退到不定高）。
        itemExtent: useItemExtent ? _rowHeight : null,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // 每行包 RepaintBoundary：滚动时各行独立图层，互不重绘。
          return RepaintBoundary(
            child: _FixedHeightRow(index: index, height: _rowHeight),
          );
        },
      ),
    );
  }
}

/// 固定高度的列表行。除 [index] 外全部 const，rebuild 成本最低。
class _FixedHeightRow extends StatelessWidget {
  const _FixedHeightRow({required this.index, required this.height});

  final int index;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
        child: Row(
          children: <Widget>[
            CircleAvatar(child: Text('$index')),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('列表项 #$index', style: theme.textTheme.titleSmall),
                  Text(
                    '固定行高 ${height.toInt()}px · RepaintBoundary 隔离',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
