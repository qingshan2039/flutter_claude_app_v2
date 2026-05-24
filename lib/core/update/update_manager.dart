import 'package:flutter_claude_app_v2/core/update/app_version.dart';
import 'package:flutter_claude_app_v2/core/update/update_models.dart';
import 'package:flutter_claude_app_v2/core/update/version_check_service.dart';
import 'package:injectable/injectable.dart';

/// 更新决策中枢（T23.1 / T23.2）。
///
/// 把「当前版本 + 后端信息」映射成 [UpdatePolicy]：
/// - `current >= latest` → upToDate
/// - `current < minSupported` → **force**（强制）
/// - 否则（minSupported ≤ current < latest）：`preferSilent` → silent，否则 optional
///
/// [decide] 是**纯函数**（易测）；[check] 负责拉取后端信息再决策。
@lazySingleton
class UpdateManager {
  const UpdateManager(this._service);

  final VersionCheckService _service;

  /// 纯决策：不发网络，给定输入即可推出策略。
  UpdateDecision decide({
    required AppVersion current,
    required UpdateInfo info,
  }) {
    final UpdatePolicy policy;
    if (current >= info.latestVersion) {
      policy = UpdatePolicy.upToDate;
    } else if (current < info.minSupportedVersion) {
      policy = UpdatePolicy.force;
    } else if (info.preferSilent) {
      policy = UpdatePolicy.silent;
    } else {
      policy = UpdatePolicy.optional;
    }
    return UpdateDecision(policy: policy, currentVersion: current, info: info);
  }

  /// 拉取后端信息并决策。
  Future<UpdateDecision> check({required AppVersion current}) async {
    final info = await _service.fetchLatest();
    return decide(current: current, info: info);
  }
}
