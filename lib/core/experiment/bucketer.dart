/// 用户分桶（T31.1）。
///
/// 把「分桶单位」（userId / 设备 ID）稳定哈希到 `[0, buckets)`，用于灰度发布与
/// A/B 实验的变体分发。用 FNV-1a 保证**跨平台/跨运行稳定**（同一 unitId + salt
/// 永远落同一桶），不依赖 `String.hashCode` 的实现细节。
///
/// `salt` 一般传实验/功能的 key，使不同实验的分桶相互独立（避免相关性）。
abstract final class Bucketer {
  static int _fnv1a(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash = (hash ^ unit) & 0xffffffff;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  /// 把 [unitId] 稳定分桶到 `[0, buckets)`（默认 100）。
  static int bucketOf(String unitId, {String salt = '', int buckets = 100}) {
    assert(buckets > 0, 'buckets 必须为正');
    return _fnv1a('$salt:$unitId') % buckets;
  }

  /// 解析分桶单位：优先 userId（登录态稳定），否则设备 ID，否则匿名常量。
  static String resolveUnitId({String? userId, String? deviceId}) {
    if (userId != null && userId.isNotEmpty) return userId;
    if (deviceId != null && deviceId.isNotEmpty) return deviceId;
    return 'anonymous';
  }

  /// [unitId] 是否命中 [percent]% 灰度（salt 区分不同灰度）。
  static bool isInRollout(
    String unitId, {
    required int percent,
    String salt = '',
  }) {
    if (percent <= 0) return false;
    if (percent >= 100) return true;
    return bucketOf(unitId, salt: salt) < percent;
  }
}
