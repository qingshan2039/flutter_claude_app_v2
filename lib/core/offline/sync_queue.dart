import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:injectable/injectable.dart';

/// 一个待同步的离线操作（T25.2）。
@immutable
class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      PendingOperation(
        id: json['id'] as String,
        type: json['type'] as String,
        payload: (json['payload'] as Map).cast<String, dynamic>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
      );

  final String id;

  /// 操作类型（如 `createPost` / `deleteItem`），由业务定义。
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  PendingOperation copyWith({int? retryCount}) => PendingOperation(
    id: id,
    type: type,
    payload: payload,
    createdAt: createdAt,
    retryCount: retryCount ?? this.retryCount,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
  };
}

/// 同步结果（T25.2）。
@immutable
class SyncReport {
  const SyncReport({required this.synced, required this.failed});
  final int synced;
  final int failed;
}

/// 本地变更队列（T25.2）。
///
/// 离线时把写操作 [enqueue] 到持久化队列；恢复在线后调用 [flush] 逐个重放：
/// 成功移除、失败保留并累加 [PendingOperation.retryCount]。配合
/// `ConnectivityService`（T25.4）在网络恢复时触发。
@lazySingleton
class SyncQueue {
  const SyncQueue(this._storage);

  final KeyValueStorage _storage;

  static const String _key = 'offline.sync_queue';

  /// 当前队列（按入队顺序）。
  List<PendingOperation> all() {
    final raw = _storage.getString(_key);
    if (raw == null) return <PendingOperation>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PendingOperation.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } on FormatException {
      return <PendingOperation>[];
    }
  }

  int get length => all().length;
  bool get isEmpty => all().isEmpty;

  Future<void> _save(List<PendingOperation> ops) =>
      _storage.setString(_key, jsonEncode(ops.map((o) => o.toJson()).toList()));

  /// 入队一个离线操作。
  Future<void> enqueue(PendingOperation op) async {
    final ops = all()..add(op);
    await _save(ops);
  }

  /// 按 id 移除。
  Future<void> remove(String id) async {
    final ops = all()..removeWhere((o) => o.id == id);
    await _save(ops);
  }

  /// 清空队列。
  Future<void> clear() => _storage.remove(_key);

  /// 恢复在线后逐个重放：[handler] 返回 true 视为同步成功（移除），否则保留并 retry+1。
  Future<SyncReport> flush(
    Future<bool> Function(PendingOperation op) handler,
  ) async {
    var synced = 0;
    var failed = 0;
    final remaining = <PendingOperation>[];
    for (final op in all()) {
      bool ok;
      try {
        ok = await handler(op);
      } catch (_) {
        ok = false;
      }
      if (ok) {
        synced++;
      } else {
        failed++;
        remaining.add(op.copyWith(retryCount: op.retryCount + 1));
      }
    }
    await _save(remaining);
    return SyncReport(synced: synced, failed: failed);
  }
}
