import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/privacy/legal_documents.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 法律文档展示页（T24.5）：渲染 [LegalDocument]（隐私政策 / 用户协议）。
///
/// 顶部展示**版本与生效日期**（版本管理），正文按章节「标题 + 段落」结构化渲染
/// （富文本：标题/正文样式分层；如需图文/链接可扩展为 markdown/flutter_html）。
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({required this.document, super.key});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = document.effectiveDate;
    final dateText =
        '${date.year}-${_two(date.month)}-${_two(date.day)}';

    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: <Widget>[
          Text(
            '版本 ${document.version} · 生效日期 $dateText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          for (final section in document.sections) ...<Widget>[
            Text(section.heading, style: theme.textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.xs),
            Text(section.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: SpacingTokens.md),
          ],
        ],
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
