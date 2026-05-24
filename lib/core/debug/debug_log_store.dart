import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// 日志级别（与 AppLogger 对齐，按严重度排序）。
enum DebugLogLevel { trace, debug, info, warning, error }

/// 一条内存日志记录（T29.3）。
@immutable
class DebugLogRecord {
  const DebugLogRecord({
    required this.level,
    required this.message,
    required this.time,
  });

  final DebugLogLevel level;
  final String message;
  final DateTime time;
}

/// 内存日志缓冲（T29.3）。
///
/// 环形缓冲（超过 [capacity] 丢弃最旧），供 Debug 面板日志查看器实时展示、过滤、
/// 搜索、导出。接入方式：在 AppLogger 的自定义 Output 里调用 [add]（M11 集成点）。
@lazySingleton
class DebugLogStore {
  DebugLogStore();

  /// 最大保留条数（公开字段，避免基本类型构造参数让 injectable 解析失败）。
  int capacity = 500;

  final List<DebugLogRecord> _records = <DebugLogRecord>[];

  List<DebugLogRecord> get records => List<DebugLogRecord>.unmodifiable(_records);

  int get length => _records.length;

  void add(DebugLogLevel level, String message, {DateTime? time}) {
    _records.add(
      DebugLogRecord(level: level, message: message, time: time ?? DateTime.now()),
    );
    while (_records.length > capacity) {
      _records.removeAt(0);
    }
  }

  /// 按最低级别 + 关键词过滤（[query] 不区分大小写）。
  List<DebugLogRecord> filter({DebugLogLevel? minLevel, String? query}) {
    final q = query?.trim().toLowerCase();
    return _records.where((r) {
      if (minLevel != null && r.level.index < minLevel.index) return false;
      if (q != null && q.isNotEmpty && !r.message.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  void clear() => _records.clear();

  /// 导出为纯文本（一键导出/分享）。
  String exportAsText() => _records
      .map(
        (r) =>
            '[${r.level.name.toUpperCase()}] ${r.time.toIso8601String()} ${r.message}',
      )
      .join('\n');
}
