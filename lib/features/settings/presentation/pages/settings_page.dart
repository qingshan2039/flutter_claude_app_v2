import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/i18n/locale_provider.dart';
import 'package:flutter_claude_app_v2/core/router/auth_redirect.dart';
import 'package:flutter_claude_app_v2/core/router/route_names.dart';
import 'package:flutter_claude_app_v2/core/theme/theme_mode_provider.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_claude_app_v2/shared/utils/overlay_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 设置页（T19.4）：语言切换 + 主题切换 + 退出登录 + 账户注销。
///
/// Shell 的第三个 Tab。语言/主题复用 M08/M10 的 provider（自动持久化）。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          const _SectionTitle('语言'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<String>>[
                ButtonSegment(value: 'system', label: Text('跟随系统')),
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'zh', label: Text('中文')),
              ],
              selected: <String>{locale?.languageCode ?? 'system'},
              onSelectionChanged: (s) {
                final v = s.first;
                ref.read(localeProvider.notifier).setLocale(
                  v == 'system' ? null : Locale(v),
                );
              },
            ),
          ),
          const _SectionTitle('主题'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment(value: ThemeMode.system, label: Text('系统')),
                ButtonSegment(value: ThemeMode.light, label: Text('亮色')),
                ButtonSegment(value: ThemeMode.dark, label: Text('暗色')),
              ],
              selected: <ThemeMode>{themeMode},
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).setThemeMode(s.first),
            ),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('权限演示'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(RouteNames.permissions),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('退出登录'),
            onTap: () => _signOut(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
            title: Text('注销账户', style: TextStyle(color: scheme.error)),
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await getIt<AuthRepository>().signOut();
    ref.read(isLoggedInProvider.notifier).state = false;
    if (context.mounted) context.goNamed(RouteNames.login);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final ok = await getIt<OverlayService>().showConfirm(
      title: '注销账户',
      message: '注销后账户数据将无法恢复，确认继续？',
      confirmLabel: '注销',
      destructive: true,
    );
    if (!ok) return;
    await getIt<AuthRepository>().signOut();
    ref.read(isLoggedInProvider.notifier).state = false;
    getIt<OverlayService>().showSuccess('账户已注销');
    if (context.mounted) context.goNamed(RouteNames.login);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
