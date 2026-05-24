import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 弹出隐私同意对话框（T24.1），返回用户是否同意。
///
/// 不可通过返回键/点遮罩关闭（必须明确选择）。点「不同意」进入**二次确认**，
/// 再次「仍不同意」才返回 false；「返回同意」退回首屏。
Future<bool> showPrivacyConsent(
  BuildContext context, {
  required String version,
  VoidCallback? onViewPrivacy,
  VoidCallback? onViewAgreement,
}) async {
  final agreed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PrivacyConsentDialog(
      version: version,
      onViewPrivacy: onViewPrivacy,
      onViewAgreement: onViewAgreement,
    ),
  );
  return agreed ?? false;
}

/// 隐私同意弹窗（T24.1）：首次启动展示，含二次确认机制。
class PrivacyConsentDialog extends StatefulWidget {
  const PrivacyConsentDialog({
    required this.version,
    super.key,
    this.onViewPrivacy,
    this.onViewAgreement,
  });

  final String version;
  final VoidCallback? onViewPrivacy;
  final VoidCallback? onViewAgreement;

  @override
  State<PrivacyConsentDialog> createState() => _PrivacyConsentDialogState();
}

class _PrivacyConsentDialogState extends State<PrivacyConsentDialog> {
  bool _confirmingDecline = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false, // 必须明确选择，不能返回键关闭
      child: _confirmingDecline
          ? AlertDialog(
              title: const Text('确认不同意？'),
              content: const Text('不同意隐私政策将无法使用本应用的完整功能。'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('仍不同意'),
                ),
                FilledButton(
                  onPressed: () => setState(() => _confirmingDecline = false),
                  child: const Text('返回同意'),
                ),
              ],
            )
          : AlertDialog(
              title: const Text('隐私政策与用户协议'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '为向你提供服务，我们会按隐私政策处理必要信息。统计/推送等可选 '
                    'SDK 仅在你同意后启用。请阅读并同意以继续。',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Wrap(
                    children: <Widget>[
                      TextButton(
                        onPressed: widget.onViewPrivacy,
                        child: const Text('《隐私政策》'),
                      ),
                      TextButton(
                        onPressed: widget.onViewAgreement,
                        child: const Text('《用户协议》'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => setState(() => _confirmingDecline = true),
                  child: const Text('不同意'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('同意并继续'),
                ),
              ],
            ),
    );
  }
}
