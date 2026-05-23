import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 空状态组件（T14.1）。
///
/// 「列表为空 / 无搜索结果 / 无收藏」等场景。可选 [onAction] 提供一个引导操作
/// （如「去添加」「重新搜索」）。
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = '暂无数据',
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// 操作按钮文案；与 [onAction] 同时提供才显示按钮。
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAction = onAction != null && actionLabel != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            SpacingTokens.gapMd,
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (message != null) ...<Widget>[
              SpacingTokens.gapSm,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (hasAction) ...<Widget>[
              SpacingTokens.gapLg,
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
