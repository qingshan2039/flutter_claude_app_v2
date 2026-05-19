import 'package:hive_ce/hive.dart';

/// 单步迁移函数签名。失败时抛异常 → [DatabaseMigrator.runIfNeeded] 中断不再升级版本号。
///
/// `currentVersion` 是迁移前的旧版本号（从此值升级到 `currentVersion + 1`）。
typedef Migration = Future<void> Function(int currentVersion);

/// 数据库 schema 版本管理器（T05.4）。
///
/// 设计原则：
/// - 在元数据 box（默认 `app_meta`）的 `schema_version` 键存储当前版本号
/// - 版本号 0 = 全新安装；首次启动会按顺序执行 `migrations[0]`、`migrations[1]`、...
/// - 每个 [Migration] 应**幂等且可恢复**（中途失败可下次启动继续）
/// - 迁移完成后才更新版本号，避免半成功状态
///
/// 使用：
/// ```dart
/// final migrator = DatabaseMigrator(
///   targetVersion: 2,
///   migrations: [
///     (_) async { /* v0 → v1 */ },
///     (_) async { /* v1 → v2 */ },
///   ],
/// );
/// await migrator.runIfNeeded();
/// ```
class DatabaseMigrator {
  DatabaseMigrator({
    required this.targetVersion,
    required this.migrations,
    this.metaBoxName = _defaultMetaBoxName,
  }) : assert(
         targetVersion >= 0,
         'targetVersion must be non-negative',
       ),
       assert(
         migrations.length >= targetVersion,
         'migrations 列表长度必须 ≥ targetVersion，'
         '当前 targetVersion=$targetVersion 但 migrations.length=${migrations.length}',
       );

  static const String _defaultMetaBoxName = 'app_meta';
  static const String _versionKey = 'schema_version';

  /// 期望升到的目标版本号。
  final int targetVersion;

  /// 按顺序排列的迁移函数：`migrations[i]` 把 schema 从版本 `i` 升级到 `i + 1`。
  final List<Migration> migrations;

  /// 存放 `schema_version` 的 meta box 名称。
  final String metaBoxName;

  /// 当前版本号；测试 / 调试用。返回 null 表示元数据 box 尚未打开。
  int? _lastReadVersion;
  int? get lastReadVersion => _lastReadVersion;

  /// 必要时执行迁移。
  ///
  /// 调用前应先 `Hive.init(...)` 或 `Hive.initFlutter()`。
  Future<void> runIfNeeded() async {
    final meta = await Hive.openBox<dynamic>(metaBoxName);
    try {
      final current = (meta.get(_versionKey) as int?) ?? 0;
      _lastReadVersion = current;

      if (current >= targetVersion) {
        return; // 已是最新版本
      }

      for (var v = current; v < targetVersion; v++) {
        await migrations[v](v);
      }

      await meta.put(_versionKey, targetVersion);
      _lastReadVersion = targetVersion;
    } finally {
      await meta.close();
    }
  }

  /// 测试辅助：直接清空版本号（仅在测试中使用）。
  Future<void> debugResetVersion() async {
    final meta = await Hive.openBox<dynamic>(metaBoxName);
    try {
      await meta.delete(_versionKey);
      _lastReadVersion = null;
    } finally {
      await meta.close();
    }
  }
}
