import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/core/update/update_models.dart';

/// 弹出更新对话框（T23.2），返回用户是否选择「立即更新」。
///
/// - **强制**（[UpdateDecision.isForced]）：不可关闭（无「稍后」、屏蔽返回键、点遮罩不关）。
/// - **提示**（optional）：可「稍后」（返回 false）或「立即更新」（返回 true）。
/// - **静默**（silent）：不应弹此对话框，由调用方走后台下载流程（这里不处理）。
Future<bool> showUpdateDialog(
  BuildContext context,
  UpdateDecision decision,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: !decision.isForced,
    builder: (_) => UpdateDialog(decision: decision),
  );
  return result ?? false;
}

/// 更新提示对话框 UI（T23.2）。
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({required this.decision, super.key});

  final UpdateDecision decision;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final forced = decision.isForced;
    final info = decision.info;

    return PopScope(
      // 强制更新时屏蔽返回键，无法退出对话框。
      canPop: !forced,
      child: AlertDialog(
        title: Text(forced ? '需要更新' : '发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '最新版本 ${info.latestVersion}（当前 ${decision.currentVersion}）',
              style: theme.textTheme.bodyMedium,
            ),
            if (info.releaseNotes.isNotEmpty) ...<Widget>[
              const SizedBox(height: SpacingTokens.sm),
              Text(info.releaseNotes, style: theme.textTheme.bodySmall),
            ],
            if (forced) ...<Widget>[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                '当前版本过低，需更新后才能继续使用。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        actions: <Widget>[
          if (!forced)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('稍后'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }
}
