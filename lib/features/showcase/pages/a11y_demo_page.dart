import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/a11y/wcag_contrast.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/color_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/examples/a11y/focus_management_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_claude_app_v2/shared/widgets/min_tap_target.dart';

/// M22 无障碍（a11y）demo：最小点击区域 + 语义标签 + 对比度 + 焦点管理。
class A11yDemoPage extends StatelessWidget {
  const A11yDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      moduleId: 'M22',
      title: '无障碍（a11y）',
      children: <Widget>[
        DemoSection(
          title: '最小点击区域（T22.3）',
          description: '小图标用 MinTapTarget 包裹，命中区域撑到 48×48（虚线框），'
              '视觉尺寸不变。',
          child: Row(
            children: <Widget>[
              for (final icon in <IconData>[
                Icons.favorite_border,
                Icons.share_outlined,
                Icons.close,
              ])
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: MinTapTarget(
                    onTap: () {},
                    semanticLabel: '操作',
                    child: Icon(icon, size: 16),
                  ),
                ),
            ],
          ),
        ),
        DemoSection(
          title: '语义标签（T22.1）',
          description: 'Semantics 为纯图标/自定义控件补充屏幕阅读器朗读文本；'
              'MergeSemantics 把一组拆散的语义合并成一句。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                label: '已认证用户',
                child: const Icon(Icons.verified, color: Colors.blue),
              ),
              const SizedBox(height: SpacingTokens.sm),
              const MergeSemantics(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.star, size: 18),
                    SizedBox(width: 4),
                    Text('4.8 分（共 1200 条评价）'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '颜色对比度（T22.2）',
          description: '业务语义色与配对前景色的 WCAG 对比度（均 ≥ AA 4.5:1）。',
          child: _ContrastReport(),
        ),
        DemoSection(
          title: '焦点管理（T22.5）',
          description: 'FocusTraversalGroup + NumericFocusOrder 控制 Tab 顺序；'
              'FocusNode 手动聚焦。',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FocusManagementPage(),
                ),
              ),
              icon: const Icon(Icons.keyboard_tab),
              label: const Text('打开焦点管理示例'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContrastReport extends StatelessWidget {
  const _ContrastReport();

  @override
  Widget build(BuildContext context) {
    const rows = <(String, Color, Color)>[
      ('success', ColorTokens.onSuccess, ColorTokens.success),
      ('warning', ColorTokens.onWarning, ColorTokens.warning),
      ('info', ColorTokens.onInfo, ColorTokens.info),
    ];
    return Column(
      children: <Widget>[
        for (final (name, fg, bg) in rows)
          Container(
            margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
            padding: const EdgeInsets.all(SpacingTokens.sm),
            color: bg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(name, style: TextStyle(color: fg)),
                Text(
                  '${WcagContrast.ratio(fg, bg).toStringAsFixed(2)}:1  '
                  '[${WcagContrast.grade(fg, bg)}]',
                  style: TextStyle(color: fg),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
