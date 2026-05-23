import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/detail/domain/entities/article_detail.dart';
import 'package:flutter_claude_app_v2/features/detail/presentation/providers/article_detail_provider.dart';
import 'package:flutter_claude_app_v2/shared/widgets/async_value_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 详情页（T19.3）：路由参数 [id] + 异步加载 + AsyncValue 三态。
class DetailPage extends ConsumerWidget {
  const DetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(articleDetailProvider(id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('详情 #$id')),
      body: AsyncValueWidget<ArticleDetail>(
        value: article,
        onRetry: () => ref.invalidate(articleDetailProvider(id)),
        data: (a) => ListView(
          padding: SpacingTokens.pagePadding,
          children: <Widget>[
            Text(a.title, style: theme.textTheme.headlineSmall),
            SpacingTokens.gapSm,
            Text(
              '作者：${a.author}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: SpacingTokens.lg),
            Text(a.body, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
