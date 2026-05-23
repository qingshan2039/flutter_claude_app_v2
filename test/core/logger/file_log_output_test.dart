import 'dart:io';

import 'package:flutter_claude_app_v2/core/logger/file_log_output.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('logfile_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('LogFileManager 按日期切割', () {
    test('fileForDate 命名格式 app-YYYY-MM-DD.log', () {
      final m = LogFileManager(directory: tempDir);
      final f = m.fileForDate(DateTime(2026, 5, 18));
      expect(f.path, endsWith('app-2026-05-18.log'));
    });

    test('append 写入对应日期文件', () async {
      final m = LogFileManager(directory: tempDir);
      await m.append('hello', now: DateTime(2026, 5, 18));
      await m.append('world', now: DateTime(2026, 5, 18));

      final f = m.fileForDate(DateTime(2026, 5, 18));
      expect(f.existsSync(), isTrue);
      expect(f.readAsStringSync(), 'hello\nworld\n');
    });

    test('不同日期写入不同文件', () async {
      final m = LogFileManager(directory: tempDir);
      await m.append('day1', now: DateTime(2026, 5, 18));
      await m.append('day2', now: DateTime(2026, 5, 19));

      expect(m.fileForDate(DateTime(2026, 5, 18)).readAsStringSync(),
          contains('day1'));
      expect(m.fileForDate(DateTime(2026, 5, 19)).readAsStringSync(),
          contains('day2'));
    });
  });

  group('LogFileManager 清理过期', () {
    test('删除早于 retentionDays 的文件', () async {
      final m = LogFileManager(directory: tempDir, retentionDays: 7);
      final now = DateTime(2026, 5, 18);

      // 旧文件（10 天前）+ 新文件（今天）
      await m.append('old', now: now.subtract(const Duration(days: 10)));
      await m.append('recent', now: now);

      final deleted = await m.cleanupExpired(now: now);

      expect(deleted, 1);
      expect(
        m.fileForDate(now.subtract(const Duration(days: 10))).existsSync(),
        isFalse,
      );
      expect(m.fileForDate(now).existsSync(), isTrue);
    });

    test('保留期内的文件不删', () async {
      final m = LogFileManager(directory: tempDir, retentionDays: 7);
      final now = DateTime(2026, 5, 18);
      await m.append('d3', now: now.subtract(const Duration(days: 3)));

      final deleted = await m.cleanupExpired(now: now);
      expect(deleted, 0);
    });

    test('非日志文件不受影响', () async {
      File('${tempDir.path}/readme.txt').writeAsStringSync('keep me');
      final m = LogFileManager(directory: tempDir, retentionDays: 1);
      final deleted = await m.cleanupExpired(now: DateTime(2026, 5, 18));
      expect(deleted, 0);
      expect(File('${tempDir.path}/readme.txt').existsSync(), isTrue);
    });
  });

  group('LogFileManager 大小限制', () {
    test('超过 maxFileSizeBytes 滚动为 .1 备份', () async {
      final m = LogFileManager(
        directory: tempDir,
        maxFileSizeBytes: 20, // 极小阈值便于触发
      );
      final now = DateTime(2026, 5, 18);

      await m.append('0123456789', now: now); // 11 bytes
      await m.append('0123456789', now: now); // 累计 22 ≥ 20 → 下次写入前滚动
      await m.append('new', now: now);

      final main = m.fileForDate(now);
      final backup = File('${main.path}.1');
      expect(backup.existsSync(), isTrue);
      expect(main.readAsStringSync(), 'new\n');
    });
  });

  group('FileLogOutput 适配', () {
    test('output 写入文件', () async {
      final m = LogFileManager(directory: tempDir);
      final out = FileLogOutput(m);

      // 直接构造 OutputEvent 触发写入（绕过完整 Logger）
      final origin = LogEvent(Level.info, 'msg');
      out.output(OutputEvent(origin, <String>['line-a', 'line-b']));
      // 给 fire-and-forget 写入一点时间
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final f = m.fileForDate(DateTime.now());
      expect(f.existsSync(), isTrue);
      final content = f.readAsStringSync();
      expect(content, contains('line-a'));
      expect(content, contains('line-b'));
    });
  });
}
