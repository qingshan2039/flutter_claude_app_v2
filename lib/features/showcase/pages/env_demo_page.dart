import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/env/env_config.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_claude_app_v2/gen/assets.gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// M15 多环境配置 — 可视化演示。
///
/// 展示当前 [EnvConfig]（由入口的 `--flavor` + `--dart-define-from-file` 决定）。
/// showcase 入口固定 dev，故这里显示 dev 配置。
class EnvDemoPage extends ConsumerWidget {
  const EnvDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(envConfigProvider);

    return DemoScaffold(
      title: '多环境配置',
      moduleId: 'M15',
      children: <Widget>[
        DemoSection(
          title: 'T15.1 当前 EnvConfig',
          description: '由 main_<env>.dart 入口解析；dart-define 可覆盖默认值',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('environment', env.environment.name),
              DemoResultRow('appName', env.appName),
              DemoResultRow('appId', env.appId),
              DemoResultRow('apiBaseUrl', env.apiBaseUrl),
              DemoResultRow('enableLogging', '${env.enableLogging}'),
              DemoResultRow('enableCrashReporting', '${env.enableCrashReporting}'),
              DemoResultRow('sentryDsn', env.hasSentryDsn ? '*** 已配置' : '(未配置)'),
            ],
          ),
        ),
        DemoSection(
          title: 'T15.2 / T15.4 三套 flavor',
          description: 'dev / staging / prod：不同包名 / AppName / Icon',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              DemoResultRow('dev', '…app.dev · CCD Dev'),
              DemoResultRow('staging', '…app.staging · CCD Staging'),
              DemoResultRow('prod', '…app · CCD'),
              SizedBox(height: 8),
              Text(
                '启动：scripts/flutter-env.sh <env> run\n'
                '或 VSCode 运行配置（.vscode/launch.json）',
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'T15.3 Dart Define 注入',
          description: '编译期常量：env/<env>.json（敏感值不入库）',
          child: const Text(
            '--dart-define-from-file=env/dev.json\n'
            '键：API_BASE_URL / SENTRY_DSN / APP_NAME / ENABLE_LOGGING / '
            'ENABLE_CRASH_REPORTING',
          ),
        ),
        DemoSection(
          title: 'T15.5 资源生成（flutter_gen）',
          description: 'pubspec assets → lib/gen/assets.gen.dart 类型安全引用',
          child: DemoResultRow('Assets.images.placeholder', Assets.images.placeholder),
        ),
      ],
    );
  }
}
