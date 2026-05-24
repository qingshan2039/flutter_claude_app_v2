import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/update/app_version.dart';
import 'package:flutter_claude_app_v2/core/update/platform/android_in_app_update.dart';
import 'package:flutter_claude_app_v2/core/update/platform/apk_updater.dart';
import 'package:flutter_claude_app_v2/core/update/platform/store_launcher.dart';
import 'package:flutter_claude_app_v2/core/update/update_manager.dart';
import 'package:flutter_claude_app_v2/core/update/update_models.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_claude_app_v2/features/update/presentation/widgets/update_dialog.dart';

/// M23 应用内更新 demo：版本比较 + 策略决策（强制/提示/静默）+ 平台更新通道。
class UpdateDemoPage extends StatelessWidget {
  const UpdateDemoPage({super.key});

  /// 演示用「当前版本」（生产从 package_info_plus 读取）。
  static const String currentVersion = '1.3.0';

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      moduleId: 'M23',
      title: '应用内更新',
      children: <Widget>[
        const DemoSection(
          title: '版本比较（T23.1）',
          description: '当前版本 $currentVersion（SemVer 数值比较，非字典序）。',
          child: Column(
            children: <Widget>[
              DemoResultRow('1.3.0 vs 1.4.0', '1.3.0 < 1.4.0 → 有更新'),
              DemoResultRow('1.9.0 vs 1.10.0', '1.9.0 < 1.10.0（按数值）'),
              DemoResultRow('1.3.0 vs 1.2.0', '1.3.0 > 1.2.0 → 已最新'),
            ],
          ),
        ),
        DemoSection(
          title: '更新策略决策（T23.1/T23.2）',
          description: 'UpdateManager 据「当前/最新/最低支持」推出策略；提示/强制会弹窗。',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => _simulate(context, latest: '1.3.0', min: '1.0.0'),
                child: const Text('已最新'),
              ),
              FilledButton.tonal(
                onPressed: () => _simulate(context, latest: '1.4.0', min: '1.0.0'),
                child: const Text('提示更新'),
              ),
              FilledButton.tonal(
                onPressed: () => _simulate(
                  context,
                  latest: '1.4.0',
                  min: '1.0.0',
                  preferSilent: true,
                ),
                child: const Text('静默更新'),
              ),
              FilledButton(
                onPressed: () => _simulate(context, latest: '2.0.0', min: '1.5.0'),
                child: const Text('强制更新'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '平台更新通道（T23.3/T23.4/T23.5）',
          description: '各平台接缝；本机（非真机/未接入原生）会优雅降级并提示。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => _runPlatform(
                  context,
                  'Android in-app update',
                  () => getIt<AndroidInAppUpdate>().startFlexibleUpdate(),
                ),
                icon: const Icon(Icons.android),
                label: const Text('Android 应用内更新'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _runPlatform(
                  context,
                  'App Store',
                  () => getIt<StoreLauncher>()
                      .openStore('https://apps.apple.com/app/id1'),
                ),
                icon: const Icon(Icons.apple),
                label: const Text('iOS 引导至 App Store'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _runPlatform(
                  context,
                  'APK 安装',
                  () => getIt<ApkUpdater>().installApk('/tmp/app-release.apk'),
                ),
                icon: const Icon(Icons.download),
                label: const Text('国内 APK 下载安装'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _simulate(
    BuildContext context, {
    required String latest,
    required String min,
    bool preferSilent = false,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final decision = getIt<UpdateManager>().decide(
      current: AppVersion.parse(currentVersion),
      info: UpdateInfo(
        latestVersion: AppVersion.parse(latest),
        minSupportedVersion: AppVersion.parse(min),
        releaseNotes: '• 修复已知问题\n• 性能优化',
        preferSilent: preferSilent,
        storeUrl: 'https://apps.apple.com/app/id1',
        apkUrl: 'https://example.com/app-release.apk',
      ),
    );
    messenger.showSnackBar(
      SnackBar(content: Text('决策策略：${decision.policy.name}')),
    );
    if (decision.policy == UpdatePolicy.optional ||
        decision.policy == UpdatePolicy.force) {
      final go = await showUpdateDialog(context, decision);
      if (go) {
        messenger.showSnackBar(
          const SnackBar(content: Text('→ 进入平台更新流程')),
        );
      }
    }
  }

  Future<void> _runPlatform(
    BuildContext context,
    String label,
    Future<bool> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await action();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? '$label：已触发' : '$label：不可用（非真机/未接入原生，已优雅降级）',
        ),
      ),
    );
  }
}
