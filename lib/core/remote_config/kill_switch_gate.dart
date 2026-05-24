import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/remote_config/kill_switch.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 紧急下线门（T28.3 强制下线 UI）。
///
/// 包住 App（一般放在 `MaterialApp.builder` 或根 Widget）：[KillSwitch] 激活时
/// 用全屏阻塞页替换 [child]，用户无法继续使用（仅可重试）。
///
/// ```dart
/// MaterialApp(builder: (context, child) => KillSwitchGate(child: child!));
/// ```
class KillSwitchGate extends StatelessWidget {
  const KillSwitchGate({
    required this.child,
    super.key,
    this.killSwitch,
    this.active,
    this.message,
    this.onRetry,
  });

  final Widget child;

  /// 注入 KillSwitch（测试/demo）；为 null 时取 `getIt<KillSwitch>()`。
  final KillSwitch? killSwitch;

  /// 覆盖激活状态（测试/demo 预览用）；为 null 时取 KillSwitch.isActive。
  final bool? active;

  /// 覆盖文案；为 null 时取 KillSwitch.message。
  final String? message;

  final VoidCallback? onRetry;

  // 仅在需要时解析 KillSwitch（active/message 被显式覆盖时不触碰 DI）。
  KillSwitch _resolve() => killSwitch ?? getIt<KillSwitch>();

  @override
  Widget build(BuildContext context) {
    final isActive = active ?? _resolve().isActive;
    if (!isActive) return child;
    return ForcedOfflineScreen(
      message: message ?? _resolve().message,
      onRetry: onRetry,
    );
  }
}

/// 强制下线全屏页（T28.3）。用 Material 包裹以便独立或内嵌使用。
class ForcedOfflineScreen extends StatelessWidget {
  const ForcedOfflineScreen({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.cloud_off, size: 64, color: scheme.error),
              const SizedBox(height: SpacingTokens.md),
              Text(
                '服务暂时不可用',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: SpacingTokens.lg),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
