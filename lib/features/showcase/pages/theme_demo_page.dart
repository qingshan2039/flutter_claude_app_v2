import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme_extension.dart';
import 'package:flutter_claude_app_v2/core/theme/theme_mode_provider.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// M10 主题与设计系统 — 可视化演示（主题切换 + Design Tokens 色板）。
class ThemeDemoPage extends ConsumerWidget {
  const ThemeDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    return DemoScaffold(
      title: '主题与设计系统',
      moduleId: 'M10',
      children: <Widget>[
        DemoSection(
          title: '主题切换（实时）',
          description: '切换 ThemeMode，整个 App 立即换肤（已持久化）',
          child: SegmentedButton<ThemeMode>(
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.system, label: Text('系统')),
              ButtonSegment<ThemeMode>(
                  value: ThemeMode.light, label: Text('亮色')),
              ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text('暗色')),
            ],
            selected: <ThemeMode>{mode},
            onSelectionChanged: (sel) =>
                ref.read(themeModeProvider.notifier).setThemeMode(sel.first),
          ),
        ),
        DemoSection(
          title: 'ColorScheme 角色色（M3）',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _Swatch('primary', scheme.primary, scheme.onPrimary),
              _Swatch('secondary', scheme.secondary, scheme.onSecondary),
              _Swatch('tertiary', scheme.tertiary, scheme.onTertiary),
              _Swatch('error', scheme.error, scheme.onError),
              _Swatch('surface', scheme.surface, scheme.onSurface),
            ],
          ),
        ),
        DemoSection(
          title: '业务色（ThemeExtension）',
          description: 'M3 ColorScheme 没有的 success/warning/info',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _Swatch('success', appColors.success, appColors.onSuccess),
              _Swatch('warning', appColors.warning, appColors.onWarning),
              _Swatch('info', appColors.info, appColors.onInfo),
            ],
          ),
        ),
        DemoSection(
          title: 'Typography（type scale）',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('headlineSmall', style: Theme.of(context).textTheme.headlineSmall),
              Text('titleMedium', style: Theme.of(context).textTheme.titleMedium),
              Text('bodyMedium', style: Theme.of(context).textTheme.bodyMedium),
              Text('labelSmall', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
        DemoSection(
          title: 'Spacing & Radius tokens',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final (label, gap) in <(String, double)>[
                ('xs(4)', SpacingTokens.xs),
                ('md(16)', SpacingTokens.md),
                ('xl(32)', SpacingTokens.xl),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 70, child: Text(label)),
                      Container(width: gap, height: 16, color: scheme.primary),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: RadiusTokens.allSm,
                    ),
                    child: const Center(child: Text('sm')),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 56,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: RadiusTokens.allLg,
                    ),
                    child: const Center(child: Text('lg')),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 56,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: RadiusTokens.pill,
                    ),
                    child: const Center(child: Text('pill')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color, this.onColor);

  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: RadiusTokens.allMd,
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: onColor, fontSize: 12)),
    );
  }
}
