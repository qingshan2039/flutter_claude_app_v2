import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// Showcase demo 页统一脚手架：AppBar + 可滚动的 section 列表。
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    required this.title, required this.moduleId, required this.children, super.key,
  });

  final String title;
  final String moduleId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$moduleId · $title')),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: children,
      ),
    );
  }
}

/// 一个带标题/说明的演示分区卡片。
class DemoSection extends StatelessWidget {
  const DemoSection({
    required this.title, required this.child, super.key,
    this.description,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleMedium),
            if (description != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.xs),
              Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: SpacingTokens.md),
            child,
          ],
        ),
      ),
    );
  }
}

/// 一个 key-value 结果展示行（等宽值，便于看结果）。
class DemoResultRow extends StatelessWidget {
  const DemoResultRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.labelMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
