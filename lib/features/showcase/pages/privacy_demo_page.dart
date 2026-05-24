import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/privacy/account_deletion.dart';
import 'package:flutter_claude_app_v2/core/privacy/consent_store.dart';
import 'package:flutter_claude_app_v2/core/privacy/data_export.dart';
import 'package:flutter_claude_app_v2/core/privacy/legal_documents.dart';
import 'package:flutter_claude_app_v2/core/privacy/sdk_initializer.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/privacy/presentation/pages/legal_document_page.dart';
import 'package:flutter_claude_app_v2/features/privacy/presentation/widgets/privacy_consent_dialog.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M24 隐私合规 demo：同意管理 + SDK 分级 + 账户注销冷静期 + 数据导出 + 协议页。
class PrivacyDemoPage extends StatefulWidget {
  const PrivacyDemoPage({super.key});

  @override
  State<PrivacyDemoPage> createState() => _PrivacyDemoPageState();
}

class _PrivacyDemoPageState extends State<PrivacyDemoPage> {
  final ConsentStore _consent = getIt<ConsentStore>();
  final AccountDeletionService _deletion = getIt<AccountDeletionService>();

  String _sdkResult = '（未运行）';

  @override
  Widget build(BuildContext context) {
    final agreed = _consent.hasAgreed(kPrivacyPolicyVersion);
    final pending = _deletion.pendingRequest();

    return DemoScaffold(
      moduleId: 'M24',
      title: '隐私合规',
      children: <Widget>[
        DemoSection(
          title: '隐私同意（T24.1）',
          description: '首次启动弹窗，不同意有二次确认；按版本号管理重新同意。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow(
                '当前状态',
                agreed ? '已同意 v$kPrivacyPolicyVersion' : '未同意',
              ),
              const SizedBox(height: SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                children: <Widget>[
                  FilledButton(
                    onPressed: _showConsent,
                    child: const Text('显示同意弹窗'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await _consent.revoke();
                      setState(() {});
                    },
                    child: const Text('撤回同意'),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'SDK 初始化分级（T24.2）',
          description: '必要 SDK 总是初始化；可选 SDK（统计/广告）仅同意后初始化。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('本次初始化', _sdkResult),
              const SizedBox(height: SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () => _runSdk(consentGranted: false),
                    child: const Text('未同意时初始化'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _runSdk(consentGranted: true),
                    child: const Text('同意后初始化'),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: '账户注销（T24.3）',
          description: '注销进入冷静期（默认 7 天），期间可撤销；到期才清理数据。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow(
                '注销状态',
                pending == null
                    ? '无'
                    : '冷静期中，剩余 ${_deletion.remainingDays()} 天',
              ),
              const SizedBox(height: SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                children: <Widget>[
                  FilledButton(
                    onPressed: pending == null
                        ? () async {
                            await _deletion.requestDeletion();
                            setState(() {});
                          }
                        : null,
                    child: const Text('发起注销'),
                  ),
                  OutlinedButton(
                    onPressed: pending == null
                        ? null
                        : () async {
                            await _deletion.cancelDeletion();
                            setState(() {});
                          },
                    child: const Text('撤销注销'),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: '数据导出（T24.4 · GDPR）',
          description: '聚合各模块用户数据为 JSON，供用户带走。',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _exportData,
              icon: const Icon(Icons.download),
              label: const Text('导出我的数据'),
            ),
          ),
        ),
        DemoSection(
          title: '协议页（T24.5）',
          description: '隐私政策 / 用户协议，含版本与生效日期。',
          child: Wrap(
            spacing: SpacingTokens.sm,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => _openLegal(kPrivacyPolicy),
                child: const Text('隐私政策'),
              ),
              OutlinedButton(
                onPressed: () => _openLegal(kUserAgreement),
                child: const Text('用户协议'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showConsent() async {
    final agreed = await showPrivacyConsent(
      context,
      version: kPrivacyPolicyVersion,
      onViewPrivacy: () => _openLegal(kPrivacyPolicy),
      onViewAgreement: () => _openLegal(kUserAgreement),
    );
    if (agreed) {
      await _consent.agree(kPrivacyPolicyVersion);
    }
    if (mounted) setState(() {});
  }

  Future<void> _runSdk({required bool consentGranted}) async {
    final initializer = SdkInitializer()
      ..register(
        SdkComponent(
          name: 'crash',
          tier: SdkTier.essential,
          init: () async {},
        ),
      )
      ..register(
        SdkComponent(
          name: 'analytics',
          tier: SdkTier.optional,
          init: () async {},
        ),
      )
      ..register(
        SdkComponent(name: 'ads', tier: SdkTier.optional, init: () async {}),
      );
    final ran = await initializer.initialize(consentGranted: consentGranted);
    setState(() => _sdkResult = ran.join('、'));
  }

  Future<void> _exportData() async {
    final service = DataExportService()
      ..register(_DemoProfileSource())
      ..register(_DemoSettingsSource());
    final json = await service.exportAsJson();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('导出数据（JSON）'),
        content: SingleChildScrollView(child: Text(json)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _openLegal(LegalDocument doc) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LegalDocumentPage(document: doc)),
    );
  }
}

class _DemoProfileSource implements DataExportSource {
  @override
  String get section => 'profile';
  @override
  Future<Map<String, dynamic>> collect() async => <String, dynamic>{
    'name': '演示用户',
    'email': 'demo@example.com',
  };
}

class _DemoSettingsSource implements DataExportSource {
  @override
  String get section => 'settings';
  @override
  Future<Map<String, dynamic>> collect() async => <String, dynamic>{
    'locale': 'zh',
    'themeMode': 'system',
  };
}
