import 'dart:io';

import 'package:flutter_claude_app_v2/core/storage/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late HiveAppDatabase db;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>(
      HiveAppDatabase.recentQueriesBoxName,
    );
    db = HiveAppDatabase(box);
  });

  tearDown(() async {
    await db.close();
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('初始 recentQueries 为空', () {
    expect(db.recentQueries, isEmpty);
  });

  test('addRecentQuery 按插入顺序追加', () async {
    await db.addRecentQuery('flutter');
    await db.addRecentQuery('dart');
    await db.addRecentQuery('hive');
    expect(db.recentQueries, <String>['flutter', 'dart', 'hive']);
  });

  test('clearRecentQueries 清空所有', () async {
    await db.addRecentQuery('a');
    await db.addRecentQuery('b');
    await db.clearRecentQueries();
    expect(db.recentQueries, isEmpty);
  });

  test('数据写入后再次打开 box 仍能读到（持久化）', () async {
    await db.addRecentQuery('persisted');
    await db.close();

    final reopened = await Hive.openBox<String>(
      HiveAppDatabase.recentQueriesBoxName,
    );
    final db2 = HiveAppDatabase(reopened);
    expect(db2.recentQueries, <String>['persisted']);
    await db2.close();
  });
}
