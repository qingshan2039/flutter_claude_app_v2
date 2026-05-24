import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/a11y_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/di_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/env_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/error_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/i18n_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/logging_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/network_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/performance_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/permission_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/responsive_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/routing_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/state_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/storage_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/theme_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/ui_kit_demo_page.dart';

/// 单个模块在画廊中的条目。
class ShowcaseEntry {
  const ShowcaseEntry({
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String moduleId;
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

/// 所有 demo 模块注册表（M02-M12）。
///
/// 注意：`builder` 是闭包（非 const），故本列表用 `final` 而非 `const`。
final List<ShowcaseEntry> kShowcaseEntries = <ShowcaseEntry>[
  ShowcaseEntry(
    moduleId: 'M02',
    title: '依赖注入与数据建模',
    subtitle: 'get_it / injectable · freezed / json',
    icon: Icons.account_tree,
    builder: (_) => const DiDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M03',
    title: '错误处理体系',
    subtitle: 'Exception → Failure → Result',
    icon: Icons.error_outline,
    builder: (_) => const ErrorDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M04',
    title: '网络层',
    subtitle: 'dio · 拦截器链 · 脱敏',
    icon: Icons.cloud_outlined,
    builder: (_) => const NetworkDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M05',
    title: '本地存储',
    subtitle: 'SharedPreferences · SecureStorage · Hive',
    icon: Icons.save_outlined,
    builder: (_) => const StorageDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M06',
    title: '状态管理',
    subtitle: 'Riverpod providers',
    icon: Icons.bolt_outlined,
    builder: (_) => const StateDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M07',
    title: '路由管理',
    subtitle: 'go_router · 转场 · 参数',
    icon: Icons.alt_route,
    builder: (_) => const RoutingDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M08',
    title: '国际化',
    subtitle: '实时切换语言 · 复数/日期/货币',
    icon: Icons.translate,
    builder: (_) => const I18nDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M09',
    title: '权限管理',
    subtitle: '三态结果 · 永久拒绝引导',
    icon: Icons.lock_open_outlined,
    builder: (_) => const PermissionDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M10',
    title: '主题与设计系统',
    subtitle: '主题切换 · Design Tokens 色板',
    icon: Icons.palette_outlined,
    builder: (_) => const ThemeDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M11',
    title: '日志与监控',
    subtitle: '分级日志 · 脱敏 · 性能埋点',
    icon: Icons.monitor_heart_outlined,
    builder: (_) => const LoggingDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M12',
    title: '多屏幕适配',
    subtitle: '断点 · ResponsiveBuilder · Master-Detail',
    icon: Icons.devices,
    builder: (_) => const ResponsiveDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M14',
    title: '通用 UI 组件',
    subtitle: '状态组件 · AsyncValue · 刷新 · Toast/Sheet · AppScaffold',
    icon: Icons.widgets_outlined,
    builder: (_) => const UiKitDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M15',
    title: '多环境配置',
    subtitle: 'EnvConfig · flavor · dart-define · flutter_gen',
    icon: Icons.tune,
    builder: (_) => const EnvDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M21',
    title: '性能优化体系',
    subtitle: '启动埋点 · 高性能长列表 · 图片缓存',
    icon: Icons.speed,
    builder: (_) => const PerformanceDemoPage(),
  ),
  ShowcaseEntry(
    moduleId: 'M22',
    title: '无障碍（a11y）',
    subtitle: '最小点击区域 · 语义 · 对比度 · 焦点',
    icon: Icons.accessibility_new,
    builder: (_) => const A11yDemoPage(),
  ),
];

/// Showcase 画廊首页：列出所有模块 demo，点击进入。
class ShowcaseGalleryPage extends StatelessWidget {
  const ShowcaseGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模块效果展示 · Showcase')),
      body: ListView.separated(
        padding: const EdgeInsets.all(SpacingTokens.md),
        itemCount: kShowcaseEntries.length,
        separatorBuilder: (_, _) => const SizedBox(height: SpacingTokens.sm),
        itemBuilder: (context, index) {
          final entry = kShowcaseEntries[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(entry.icon)),
              title: Text('${entry.moduleId} · ${entry.title}'),
              subtitle: Text(entry.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: entry.builder),
              ),
            ),
          );
        },
      ),
    );
  }
}
