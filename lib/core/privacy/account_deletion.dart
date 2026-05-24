import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/privacy/user_data_eraser.dart';
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:injectable/injectable.dart';

/// 账户注销请求（T24.3）。
@immutable
class DeletionRequest {
  const DeletionRequest({required this.requestedAt, required this.scheduledAt});

  /// 发起注销的时间。
  final DateTime requestedAt;

  /// 冷静期结束、将执行清理的时间。
  final DateTime scheduledAt;
}

/// 账户注销服务（T24.3）：注销流程 + **冷静期** + 数据清理。
///
/// 合规与体验：注销不立即抹除，而是进入**冷静期**（默认 7 天），期间用户可
/// [cancelDeletion] 撤销；冷静期结束后 [finalizeIfDue] 触发 [UserDataEraser] 清理。
///
/// 冷静期数学是**纯静态函数**（[isDue]/[daysRemaining]），便于单测。
@LazySingleton()
class AccountDeletionService {
  const AccountDeletionService(this._storage, this._eraser);

  final KeyValueStorage _storage;
  final UserDataEraser _eraser;

  /// 默认冷静期。
  static const Duration coolingOff = Duration(days: 7);

  static const String _requestedAtKey = 'account.deletion.requestedAt';

  /// 是否已到执行时间（now ≥ requestedAt + period）。
  static bool isDue(DateTime requestedAt, DateTime now, Duration period) =>
      !now.isBefore(requestedAt.add(period));

  /// 冷静期剩余天数（向上取整，最小 0）。
  static int daysRemaining(
    DateTime requestedAt,
    DateTime now,
    Duration period,
  ) {
    final deadline = requestedAt.add(period);
    final remaining = deadline.difference(now);
    if (remaining.isNegative) return 0;
    return remaining.inHours ~/ 24 + (remaining.inHours % 24 == 0 ? 0 : 1);
  }

  /// 发起注销，进入冷静期。返回请求详情。
  Future<DeletionRequest> requestDeletion() async {
    final now = DateTime.now();
    await _storage.setString(_requestedAtKey, now.toIso8601String());
    return DeletionRequest(
      requestedAt: now,
      scheduledAt: now.add(coolingOff),
    );
  }

  /// 当前是否有待执行的注销请求。
  DeletionRequest? pendingRequest() {
    final raw = _storage.getString(_requestedAtKey);
    if (raw == null) return null;
    final requestedAt = DateTime.tryParse(raw);
    if (requestedAt == null) return null;
    return DeletionRequest(
      requestedAt: requestedAt,
      scheduledAt: requestedAt.add(coolingOff),
    );
  }

  /// 是否处于冷静期内（已请求但未到期）。
  bool isCoolingOff() {
    final pending = pendingRequest();
    if (pending == null) return false;
    return !isDue(pending.requestedAt, DateTime.now(), coolingOff);
  }

  /// 冷静期剩余天数（无请求返回 0）。
  int remainingDays() {
    final pending = pendingRequest();
    if (pending == null) return 0;
    return daysRemaining(pending.requestedAt, DateTime.now(), coolingOff);
  }

  /// 撤销注销（冷静期内）。
  Future<void> cancelDeletion() => _storage.remove(_requestedAtKey);

  /// 若冷静期已结束则执行数据清理并清除请求，返回是否执行了清理。
  ///
  /// 一般在 App 启动时调用：用户过了冷静期没撤销 → 真正抹除数据。
  Future<bool> finalizeIfDue() async {
    final pending = pendingRequest();
    if (pending == null) return false;
    if (!isDue(pending.requestedAt, DateTime.now(), coolingOff)) return false;
    await _eraser.eraseAll();
    // eraseAll 已 clear KV；防御性再删一次 key（若 eraser 未含本 key）。
    await _storage.remove(_requestedAtKey);
    return true;
  }
}
