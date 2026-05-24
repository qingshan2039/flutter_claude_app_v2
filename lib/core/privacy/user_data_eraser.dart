import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart';
import 'package:injectable/injectable.dart';

/// 用户数据清理（T24.3 数据清理）。
///
/// 账户注销冷静期结束后、或用户要求「删除我的数据」时调用，彻底清除本地用户数据。
abstract class UserDataEraser {
  Future<void> eraseAll();
}

/// 默认实现：清空键值存储 + 安全存储（token 等）。
///
/// 注：复杂数据（Hive/Isar）如有，请在此扩展清理；本模板默认只有 KV + Secure。
@LazySingleton(as: UserDataEraser)
class DefaultUserDataEraser implements UserDataEraser {
  const DefaultUserDataEraser(this._kv, this._secure);

  final KeyValueStorage _kv;
  final SecureStorage _secure;

  @override
  Future<void> eraseAll() async {
    await _kv.clear();
    await _secure.deleteAll();
  }
}
