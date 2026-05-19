import 'dart:io';

import 'package:flutter_claude_app_v2/core/storage/database/database_migrator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('migrator_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('新安装 (version 0) → 跑全部 migrations 升至 targetVersion', () async {
    final invoked = <int>[];

    final migrator = DatabaseMigrator(
      targetVersion: 3,
      migrations: <Migration>[
        (v) async => invoked.add(v),
        (v) async => invoked.add(v),
        (v) async => invoked.add(v),
      ],
    );

    await migrator.runIfNeeded();

    expect(invoked, <int>[0, 1, 2]);
    expect(migrator.lastReadVersion, 3);
  });

  test('已是最新版本 → 不跑任何 migration', () async {
    final invoked = <int>[];

    // 先升到 v2
    await DatabaseMigrator(
      targetVersion: 2,
      migrations: <Migration>[
        (_) async {},
        (_) async {},
      ],
    ).runIfNeeded();

    // 再次跑 targetVersion=2
    final migrator2 = DatabaseMigrator(
      targetVersion: 2,
      migrations: <Migration>[
        (v) async => invoked.add(v),
        (v) async => invoked.add(v),
      ],
    );
    await migrator2.runIfNeeded();

    expect(invoked, isEmpty);
    expect(migrator2.lastReadVersion, 2);
  });

  test('从中间版本升级 → 只跑缺失部分', () async {
    // 先升到 v1
    await DatabaseMigrator(
      targetVersion: 1,
      migrations: <Migration>[(_) async {}],
    ).runIfNeeded();

    // 然后从 v1 升到 v3
    final invoked = <int>[];
    final migrator = DatabaseMigrator(
      targetVersion: 3,
      migrations: <Migration>[
        (v) async => invoked.add(v),
        (v) async => invoked.add(v),
        (v) async => invoked.add(v),
      ],
    );
    await migrator.runIfNeeded();

    expect(invoked, <int>[1, 2]);    // 跳过 0，跑 1→2 与 2→3
    expect(migrator.lastReadVersion, 3);
  });

  test('migration 抛错 → 版本号不前进', () async {
    final migrator = DatabaseMigrator(
      targetVersion: 2,
      migrations: <Migration>[
        (_) async {},                                  // v0 → v1 成功
        (_) async => throw Exception('boom'),          // v1 → v2 失败
      ],
    );

    await expectLater(
      migrator.runIfNeeded(),
      throwsA(isA<Exception>()),
    );

    // 版本号停留在 0（事务化：未到 put 步骤就抛出）
    final meta = await Hive.openBox<dynamic>('app_meta');
    expect(meta.get('schema_version'), isNull);
    await meta.close();
  });

  test('断言：migrations.length < targetVersion 时构造失败', () {
    expect(
      () => DatabaseMigrator(
        targetVersion: 3,
        migrations: <Migration>[(_) async {}],   // 只给 1 个，但需要 3 个
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('debugResetVersion 清空版本号', () async {
    final migrator = DatabaseMigrator(
      targetVersion: 1,
      migrations: <Migration>[(_) async {}],
    );
    await migrator.runIfNeeded();
    expect(migrator.lastReadVersion, 1);

    await migrator.debugResetVersion();
    expect(migrator.lastReadVersion, isNull);
  });
}
