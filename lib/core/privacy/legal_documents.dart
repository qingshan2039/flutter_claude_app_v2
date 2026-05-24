import 'package:flutter/foundation.dart';

/// 法律文档的一个章节（T24.5）。
@immutable
class LegalSection {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// 法律文档（隐私政策 / 用户协议）（T24.5）。
///
/// 含**版本管理**字段（[version] + [effectiveDate]）：政策变更须升版本号，
/// 配合 [ConsentStore]（T24.1）触发重新同意。
@immutable
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.version,
    required this.effectiveDate,
    required this.sections,
  });

  final String title;
  final String version;
  final DateTime effectiveDate;
  final List<LegalSection> sections;
}

/// 当前隐私政策版本（与 [ConsentStore] 比对，变更即需重新同意）。
const String kPrivacyPolicyVersion = '1.0.0';

/// 内置隐私政策（占位内容，上线前替换为法务定稿）。
final LegalDocument kPrivacyPolicy = LegalDocument(
  title: '隐私政策',
  version: kPrivacyPolicyVersion,
  effectiveDate: DateTime(2026, 5, 24),
  sections: const <LegalSection>[
    LegalSection(
      heading: '1. 我们收集的信息',
      body: '我们仅收集为提供服务所必需的信息，如账号信息、设备信息与使用日志。'
          '不会在未经你同意的情况下收集敏感个人信息。',
    ),
    LegalSection(
      heading: '2. 信息的使用',
      body: '收集的信息用于提供与改进服务、保障账号安全、满足法律义务。'
          '我们不会将你的个人信息出售给第三方。',
    ),
    LegalSection(
      heading: '3. SDK 与第三方',
      body: '统计、推送等可选 SDK 仅在你同意后启用（见应用内「SDK 初始化分级」）。'
          '必要功能所需的最小 SDK 在你同意前即可运行。',
    ),
    LegalSection(
      heading: '4. 你的权利',
      body: '你可随时查看、导出（数据可移植）或删除你的数据；可在设置中发起账户注销，'
          '注销设有冷静期，期间可撤销。',
    ),
    LegalSection(
      heading: '5. 联系我们',
      body: '如对隐私有任何疑问，可通过应用内反馈或 privacy@example.com 联系我们。',
    ),
  ],
);

/// 当前用户协议版本。
const String kUserAgreementVersion = '1.0.0';

/// 内置用户协议（占位内容，上线前替换为法务定稿）。
final LegalDocument kUserAgreement = LegalDocument(
  title: '用户协议',
  version: kUserAgreementVersion,
  effectiveDate: DateTime(2026, 5, 24),
  sections: const <LegalSection>[
    LegalSection(
      heading: '1. 协议的接受',
      body: '使用本应用即表示你已阅读并同意本协议。若不同意，请停止使用。',
    ),
    LegalSection(
      heading: '2. 账号与责任',
      body: '你应妥善保管账号凭证，并对账号下的活动负责。禁止从事违法或侵害他人权益的行为。',
    ),
    LegalSection(
      heading: '3. 服务变更与终止',
      body: '我们可能更新或调整服务。重大变更会提前告知。你可随时停止使用并注销账号。',
    ),
    LegalSection(
      heading: '4. 免责声明',
      body: '在法律允许范围内，本应用按「现状」提供，不对特定用途的适用性作默示担保。',
    ),
  ],
);
