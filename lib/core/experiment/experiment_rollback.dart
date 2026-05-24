import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:injectable/injectable.dart';

/// 灰度回滚（T31.3）。
///
/// 一键把某个实验「下线」：回滚后该实验的所有用户回落到对照组（见
/// [ExperimentService.resolve]）。回滚状态持久化（重启仍生效）。
///
/// 服务端回滚：把实验的 `enabled` 经 RemoteConfig（M28）下发为 false，可远程统一
/// 关停；客户端 [rollback] 用于本地/紧急快速回滚。
@lazySingleton
class ExperimentRollback {
  const ExperimentRollback(this._storage);

  final KeyValueStorage _storage;

  static const String _key = 'experiment.rolled_back';

  Set<String> rolledBack() =>
      (_storage.getStringList(_key) ?? const <String>[]).toSet();

  bool isRolledBack(String experimentKey) =>
      rolledBack().contains(experimentKey);

  /// 一键回滚：下线某实验（回落对照组）。
  Future<void> rollback(String experimentKey) async {
    final set = rolledBack()..add(experimentKey);
    await _storage.setStringList(_key, set.toList());
  }

  /// 恢复某实验（重新生效）。
  Future<void> restore(String experimentKey) async {
    final set = rolledBack()..remove(experimentKey);
    await _storage.setStringList(_key, set.toList());
  }

  /// 恢复全部实验。
  Future<void> restoreAll() => _storage.remove(_key);
}
