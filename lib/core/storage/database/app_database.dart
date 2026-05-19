import 'package:flutter_claude_app_v2/core/storage/database/database_migrator.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

/// 本地数据库抽象（T05.3）。
///
/// 当前实现基于 Hive CE：一个 String 类型的 box 演示「最近搜索记录」用例。
/// 后续业务的领域对象（如离线缓存、草稿）应：
/// 1. 在 `lib/core/storage/database/adapters/` 添加 `@HiveType` adapter
/// 2. 在 [HiveAppDatabase] 上添加新 box 的读写方法
/// 3. 在 [DatabaseModule] 中 openBox + 注册到本类
///
/// 与 [KeyValueStorage] 的区别：
/// - 本接口适合结构化数据 / 较大量数据 / 需要类型化访问
/// - 性能更好（mmap 读取，非反序列化整个文件）
abstract class AppDatabase {
  /// 最近搜索记录列表（按插入顺序）。
  List<String> get recentQueries;

  /// 追加一条搜索记录。
  Future<void> addRecentQuery(String query);

  /// 清空全部搜索记录。
  Future<void> clearRecentQueries();

  /// 关闭所有 box（应用退出 / 测试 tearDown 时调用）。
  Future<void> close();
}

/// 基于 Hive CE 的实现。
///
/// 构造函数公开是为了让单测能直接传入一个测试 box（避开 Hive.initFlutter）。
class HiveAppDatabase implements AppDatabase {
  HiveAppDatabase(this._recentQueriesBox);

  static const String recentQueriesBoxName = 'recent_queries';

  final Box<String> _recentQueriesBox;

  @override
  List<String> get recentQueries =>
      _recentQueriesBox.values.toList(growable: false);

  @override
  Future<void> addRecentQuery(String query) async {
    await _recentQueriesBox.add(query);
  }

  @override
  Future<void> clearRecentQueries() async {
    await _recentQueriesBox.clear();
  }

  @override
  Future<void> close() async {
    await _recentQueriesBox.close();
  }
}

/// 把 [AppDatabase] 注入 DI。`@preResolve` 让 DI 容器在 `configureDependencies` 时
/// 先完成 Hive 初始化 + 打开 box，之后业务代码可同步访问 `recentQueries`。
@module
abstract class DatabaseModule {
  @preResolve
  @lazySingleton
  Future<AppDatabase> provideAppDatabase() async {
    await Hive.initFlutter();

    final migrator = DatabaseMigrator(
      targetVersion: 1,
      migrations: <Migration>[
        // v0 → v1：示例迁移。当前是模板首版，不需做实际数据迁移。
        // 后续 schema 变化时在此追加 `(_) async { /* migration body */ }`。
        (_) async {},
      ],
    );
    await migrator.runIfNeeded();

    final box = await Hive.openBox<String>(HiveAppDatabase.recentQueriesBoxName);
    return HiveAppDatabase(box);
  }
}
