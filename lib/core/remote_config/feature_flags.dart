import 'package:flutter_claude_app_v2/core/remote_config/remote_config.dart';
import 'package:injectable/injectable.dart';

/// 灰度发布评估器（T28.2）。
///
/// 用**稳定哈希分桶**实现按百分比灰度：同一 `userId + flag` 始终落在同一桶（0–99），
/// 保证用户体验一致（不会今天命中明天不命中）。用 FNV-1a 保证跨平台/跨运行稳定
/// （不依赖 `String.hashCode` 的实现细节）。
abstract final class RolloutEvaluator {
  static int _fnv1a(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash = (hash ^ unit) & 0xffffffff;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  /// 稳定分桶 0–99。
  static int bucketOf(String userId, String flag) =>
      _fnv1a('$flag:$userId') % 100;

  /// [userId] 是否命中 [flag] 的 [percent]% 灰度。
  static bool isInRollout({
    required String userId,
    required String flag,
    required int percent,
  }) {
    if (percent <= 0) return false;
    if (percent >= 100) return true;
    return bucketOf(userId, flag) < percent;
  }
}

/// Feature Flag 管理（T28.2）。
///
/// 在 [RemoteConfig] 之上提供功能开关读取与灰度判断：
/// - [isEnabled]：读取布尔开关 `<flag>`。
/// - [isEnabledForUser]：读取 `<flag>.rollout`（0–100）按 [userId] 稳定灰度。
@lazySingleton
class FeatureFlags {
  const FeatureFlags(this._config);

  final RemoteConfig _config;

  bool isEnabled(String flag, {bool defaultValue = false}) =>
      _config.getBool(flag, defaultValue: defaultValue);

  /// 灰度判断：`<flag>.rollout` 百分比 + [userId] 稳定分桶。
  bool isEnabledForUser(
    String flag,
    String userId, {
    int defaultPercent = 0,
  }) {
    final percent = _config.getInt(
      '$flag.rollout',
      defaultValue: defaultPercent,
    );
    return RolloutEvaluator.isInRollout(
      userId: userId,
      flag: flag,
      percent: percent,
    );
  }

  /// 灰度命中桶（用于调试展示）。
  int bucketFor(String flag, String userId) =>
      RolloutEvaluator.bucketOf(userId, flag);
}
