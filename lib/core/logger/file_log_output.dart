import 'dart:io';

import 'package:logger/logger.dart';

/// 日志文件管理器（T11.2）。
///
/// 职责：
/// - **按日期切割**：每天一个文件 `app-YYYY-MM-DD.log`
/// - **清理过期**：启动时删除超过 [retentionDays] 的日志文件
/// - **大小限制**：单文件超过 [maxFileSizeBytes] 时滚动为 `.1` 备份
///
/// 文件 I/O 抽到本类（与 [FileLogOutput] 分离），便于用临时目录单测。
class LogFileManager {
  LogFileManager({
    required this.directory,
    this.retentionDays = 7,
    this.maxFileSizeBytes = 5 * 1024 * 1024, // 5 MB
    this.filePrefix = 'app',
  });

  final Directory directory;
  final int retentionDays;
  final int maxFileSizeBytes;
  final String filePrefix;

  /// 串行化写入队列：避免并发 append 互相覆盖 / 交错（logger 可能高频并发写）。
  Future<void> _writeQueue = Future<void>.value();

  /// 某日期对应的日志文件。
  File fileForDate(DateTime date) =>
      File('${directory.path}/$filePrefix-${_dateStamp(date)}.log');

  /// 追加一行日志（自动按需切割 / 滚动）。多次调用按入队顺序串行执行。
  Future<void> append(String line, {DateTime? now}) {
    _writeQueue = _writeQueue.then((_) => _doAppend(line, now: now));
    return _writeQueue;
  }

  Future<void> _doAppend(String line, {DateTime? now}) async {
    final date = now ?? DateTime.now();
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final file = fileForDate(date);

    // 大小限制：超限则把当前文件滚动为 .1 备份
    if (file.existsSync() && await file.length() >= maxFileSizeBytes) {
      final backup = File('${file.path}.1');
      if (backup.existsSync()) {
        backup.deleteSync();
      }
      file.renameSync(backup.path);
    }

    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }

  /// 删除早于 [retentionDays] 的日志文件。返回删除的文件数。
  Future<int> cleanupExpired({DateTime? now}) async {
    if (!directory.existsSync()) return 0;
    final cutoff =
        (now ?? DateTime.now()).subtract(Duration(days: retentionDays));
    var deleted = 0;
    for (final entity in directory.listSync()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      final date = _parseDate(name);
      if (date != null && date.isBefore(_dateOnly(cutoff))) {
        entity.deleteSync();
        deleted++;
      }
    }
    return deleted;
  }

  static String _dateStamp(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// 从文件名 `app-2026-05-18.log` 解析日期；不匹配返回 null。
  DateTime? _parseDate(String fileName) {
    final match =
        RegExp('^$filePrefix-(\\d{4})-(\\d{2})-(\\d{2})\\.log\$')
            .firstMatch(fileName);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}

/// 把 [LogFileManager] 适配为 `logger` 包的 [LogOutput]（T11.2）。
///
/// 接入：
/// ```dart
/// final manager = LogFileManager(directory: await getApplicationSupportDirectory());
/// await manager.cleanupExpired();
/// final logger = Logger(
///   output: MultiOutput([ConsoleOutput(), FileLogOutput(manager)]),
/// );
/// ```
class FileLogOutput extends LogOutput {
  FileLogOutput(this._manager);

  final LogFileManager _manager;

  @override
  void output(OutputEvent event) {
    // logger 的 output 是同步签名；文件写入 fire-and-forget。
    for (final line in event.lines) {
      _manager.append(line);
    }
  }
}
