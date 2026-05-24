import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/update/app_version.dart';

/// 更新策略三档 + 已最新（T23.2）。
enum UpdatePolicy {
  /// 已是最新，无需更新。
  upToDate,

  /// 静默更新：后台下载/安装，不打扰用户（后端建议）。
  silent,

  /// 提示更新：弹窗提示，可「稍后」。
  optional,

  /// 强制更新：当前版本低于最低支持版本，必须更新才能继续。
  force,
}

/// 后端版本检查返回的更新信息（T23.1）。
///
/// 对接契约：`GET {API}/app/version` 返回 JSON →[UpdateInfo.fromJson]。
@immutable
class UpdateInfo {
  const UpdateInfo({
    required this.latestVersion,
    required this.minSupportedVersion,
    this.releaseNotes = '',
    this.storeUrl,
    this.apkUrl,
    this.preferSilent = false,
  });

  /// 从后端 JSON 解析（字段缺省按安全默认处理）。
  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
    latestVersion: AppVersion.parse(json['latestVersion'] as String? ?? '0.0.0'),
    minSupportedVersion: AppVersion.parse(
      json['minSupportedVersion'] as String? ?? '0.0.0',
    ),
    releaseNotes: json['releaseNotes'] as String? ?? '',
    storeUrl: json['storeUrl'] as String?,
    apkUrl: json['apkUrl'] as String?,
    preferSilent: json['preferSilent'] as bool? ?? false,
  );

  /// 最新可用版本。
  final AppVersion latestVersion;

  /// 最低支持版本：当前版本低于它则**强制更新**。
  final AppVersion minSupportedVersion;

  /// 更新说明（changelog）。
  final String releaseNotes;

  /// App Store / 应用市场地址（iOS 引导更新 / Android 市场跳转）。
  final String? storeUrl;

  /// 直接下载的 APK 地址（国内 Android 旁加载更新）。
  final String? apkUrl;

  /// 后端建议静默更新（在非强制时优先静默）。
  final bool preferSilent;
}

/// 版本检查决策结果（T23.1 / T23.2）。
@immutable
class UpdateDecision {
  const UpdateDecision({
    required this.policy,
    required this.currentVersion,
    required this.info,
  });

  final UpdatePolicy policy;
  final AppVersion currentVersion;
  final UpdateInfo info;

  /// 是否有可用更新（非「已最新」）。
  bool get updateAvailable => policy != UpdatePolicy.upToDate;

  /// 是否强制更新（弹窗不可关闭）。
  bool get isForced => policy == UpdatePolicy.force;
}
