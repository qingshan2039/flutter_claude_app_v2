import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/remote_config/feature_flags.dart';
import 'package:flutter_claude_app_v2/core/remote_config/kill_switch_gate.dart';
import 'package:flutter_claude_app_v2/core/remote_config/remote_config.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M28 远程配置与 Feature Flag demo：配置拉取 + 灰度 + Kill Switch 预览。
class RemoteConfigDemoPage extends StatefulWidget {
  const RemoteConfigDemoPage({super.key});

  @override
  State<RemoteConfigDemoPage> createState() => _RemoteConfigDemoPageState();
}

class _RemoteConfigDemoPageState extends State<RemoteConfigDemoPage> {
  final RemoteConfig _config = getIt<RemoteConfig>();
  final FeatureFlags _flags = getIt<FeatureFlags>();
  final TextEditingController _userIdCtrl = TextEditingController(text: 'user_42');

  bool _simulateKill = false;
  bool _fetching = false;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userIdCtrl.text.trim();
    return DemoScaffold(
      moduleId: 'M28',
      title: '远程配置与 Feature Flag',
      children: <Widget>[
        DemoSection(
          title: '远程配置（T28.1 / T28.4）',
          description: '默认值打底 + 拉取激活 + 本地缓存。点击拉取后值会更新。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('welcome_title', _config.getString('welcome_title')),
              DemoResultRow(
                'new_checkout_enabled',
                '${_config.getBool('new_checkout_enabled')}',
              ),
              DemoResultRow('max_upload_mb', '${_config.getInt('max_upload_mb')}'),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                onPressed: _fetching ? null : _fetch,
                icon: const Icon(Icons.cloud_download_outlined),
                label: Text(_fetching ? '拉取中…' : '拉取并激活'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Feature Flag 灰度（T28.2）',
          description: 'home_banner 按 userId 稳定分桶灰度（拉取后 rollout=30%）。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(labelText: 'userId'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: SpacingTokens.sm),
              DemoResultRow(
                'bucket(0-99)',
                '${_flags.bucketFor('home_banner', userId)}',
              ),
              DemoResultRow(
                'home_banner 命中',
                '${_flags.isEnabledForUser('home_banner', userId)}',
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Kill Switch（T28.3）',
          description: '紧急下线开关；开启后用强制下线页拦截整个 App。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('模拟紧急下线'),
                value: _simulateKill,
                onChanged: (v) => setState(() => _simulateKill = v),
              ),
              const SizedBox(height: SpacingTokens.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: SizedBox(
                  height: 220,
                  child: KillSwitchGate(
                    active: _simulateKill,
                    message: '演示：服务维护中，请稍后再试',
                    onRetry: () => setState(() => _simulateKill = false),
                    child: const Center(child: Text('App 正常内容')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _fetch() async {
    setState(() => _fetching = true);
    final messenger = ScaffoldMessenger.of(context);
    final changed = await _config.fetchAndActivate();
    if (!mounted) return;
    setState(() => _fetching = false);
    messenger.showSnackBar(
      SnackBar(content: Text(changed ? '配置已更新' : '配置无变化')),
    );
  }
}
