import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/experiment/bucketer.dart';
import 'package:flutter_claude_app_v2/core/experiment/experiment.dart';
import 'package:flutter_claude_app_v2/core/experiment/experiment_rollback.dart';
import 'package:flutter_claude_app_v2/core/experiment/experiment_service.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M31 灰度发布与 A/B Test demo：分桶 + 变体分发 + 一键回滚。
class ExperimentDemoPage extends StatefulWidget {
  const ExperimentDemoPage({super.key});

  static const String experimentKey = 'button_color';

  @override
  State<ExperimentDemoPage> createState() => _ExperimentDemoPageState();
}

class _ExperimentDemoPageState extends State<ExperimentDemoPage> {
  final ExperimentService _service = getIt<ExperimentService>();
  final ExperimentRollback _rollback = getIt<ExperimentRollback>();
  final TextEditingController _userIdCtrl = TextEditingController(text: 'user_42');

  @override
  void initState() {
    super.initState();
    _service.register(
      Experiment(
        key: ExperimentDemoPage.experimentKey,
        variants: const <Variant>[
          Variant('control', weight: 50),
          Variant('blue', weight: 25),
          Variant('green', weight: 25),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitId = _userIdCtrl.text.trim();
    final rolledBack = _rollback.isRolledBack(ExperimentDemoPage.experimentKey);
    final assignment = _service.resolve(ExperimentDemoPage.experimentKey, unitId);
    final variant = assignment?.variantKey ?? '-';

    return DemoScaffold(
      moduleId: 'M31',
      title: '灰度发布与 A/B Test',
      children: <Widget>[
        DemoSection(
          title: '用户分桶（T31.1）',
          description: 'FNV-1a 稳定分桶：同一 userId 永远落同一桶。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(labelText: 'userId / 设备 ID'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: SpacingTokens.sm),
              DemoResultRow(
                'bucket(0-99)',
                '${Bucketer.bucketOf(unitId, salt: ExperimentDemoPage.experimentKey)}',
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'A/B 变体分发（T31.2）',
          description: 'button_color：control 50% / blue 25% / green 25%。'
              'activate 会上报 experiment_exposure。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('分配变体', variant),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton(
                onPressed: () => setState(() {}),
                style: FilledButton.styleFrom(
                  backgroundColor: _variantColor(variant),
                ),
                child: Text('按钮（$variant）'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              OutlinedButton.icon(
                onPressed: () => _activate(unitId),
                icon: const Icon(Icons.upload),
                label: const Text('activate（上报曝光）'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '灰度回滚（T31.3）',
          description: '一键回滚后全部用户回落对照组（control），重启仍生效。',
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(rolledBack ? '已回滚（全部 control）' : '实验进行中'),
            value: rolledBack,
            onChanged: (v) async {
              if (v) {
                await _rollback.rollback(ExperimentDemoPage.experimentKey);
              } else {
                await _rollback.restore(ExperimentDemoPage.experimentKey);
              }
              if (mounted) setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Color _variantColor(String variant) => switch (variant) {
    'blue' => Colors.blue,
    'green' => Colors.green,
    _ => Colors.grey,
  };

  Future<void> _activate(String unitId) async {
    final messenger = ScaffoldMessenger.of(context);
    final a = await _service.activate(ExperimentDemoPage.experimentKey, unitId);
    messenger.showSnackBar(
      SnackBar(content: Text('已上报曝光：variant=${a?.variantKey}')),
    );
  }
}
