import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 错误状态组件（T14.1）。
///
/// 命名为 [AppErrorView] 而非 `ErrorWidget`，避免与 Flutter 自带的
/// `ErrorWidget`（红屏）冲突。
///
/// 提供 [onRetry] 时显示「重试」按钮。
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.icon = Icons.error_outline,
    this.title = '出错了',
    this.message,
    this.retryLabel = '重试',
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64, color: theme.colorScheme.error),
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
            if (onRetry != null) ...<Widget>[
              SpacingTokens.gapLg,
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
