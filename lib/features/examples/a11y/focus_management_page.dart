import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 焦点管理示例（T22.5）。
///
/// 演示两件事：
/// 1. **显式 Tab 顺序**：`FocusTraversalGroup(policy: OrderedTraversalPolicy())`
///    配合 `FocusTraversalOrder(order: NumericFocusOrder(n))`，让键盘 Tab 顺序
///    脱离「控件出现顺序」，按业务期望走（这里字段 **视觉顺序 A、C、B**，但 Tab
///    顺序被强制为 **A → B → C**）。
/// 2. **手动焦点**：用 `FocusNode.requestFocus()` 主动聚焦，用
///    `FocusScope.of(context).unfocus()` 清除焦点 / 收起键盘。
class FocusManagementPage extends StatefulWidget {
  const FocusManagementPage({super.key});

  @override
  State<FocusManagementPage> createState() => _FocusManagementPageState();
}

class _FocusManagementPageState extends State<FocusManagementPage> {
  final FocusNode _fieldA = FocusNode(debugLabel: 'fieldA');
  final FocusNode _fieldB = FocusNode(debugLabel: 'fieldB');
  final FocusNode _fieldC = FocusNode(debugLabel: 'fieldC');
  final FocusNode _jumpTarget = FocusNode(debugLabel: 'jumpTarget');

  @override
  void dispose() {
    _fieldA.dispose();
    _fieldB.dispose();
    _fieldC.dispose();
    _jumpTarget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('焦点管理 · Tab 顺序')),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: <Widget>[
          Text(
            '1) 显式 Tab 顺序（OrderedTraversalPolicy + NumericFocusOrder）',
            style: theme.textTheme.titleMedium,
          ),
          Text(
            '视觉顺序为 A、C、B；按 Tab 实际顺序为 A → B → C。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: <Widget>[
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: TextField(
                    focusNode: _fieldA,
                    decoration: const InputDecoration(
                      labelText: '字段 A（order 1）',
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(3),
                  child: TextField(
                    focusNode: _fieldC,
                    decoration: const InputDecoration(
                      labelText: '字段 C（order 3）',
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(2),
                  child: TextField(
                    focusNode: _fieldB,
                    decoration: const InputDecoration(
                      labelText: '字段 B（order 2）',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: SpacingTokens.xl),
          Text('2) 手动焦点（FocusNode）', style: theme.textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.sm),
          TextField(
            focusNode: _jumpTarget,
            decoration: const InputDecoration(labelText: '目标输入框'),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Wrap(
            spacing: SpacingTokens.sm,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _jumpTarget.requestFocus,
                icon: const Icon(Icons.my_location),
                label: const Text('聚焦目标输入框'),
              ),
              OutlinedButton.icon(
                onPressed: () => FocusScope.of(context).unfocus(),
                icon: const Icon(Icons.keyboard_hide),
                label: const Text('清除焦点'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
