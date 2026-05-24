import 'package:flutter/painting.dart';
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart';
import 'package:injectable/injectable.dart';

/// 缓存清理工具（T29.5）。
///
/// 一键清理各类本地缓存：键值存储、安全存储、内存/磁盘图片缓存。Debug 面板调用，
/// 也可用于「清除缓存」设置项。
@lazySingleton
class CacheCleaner {
  const CacheCleaner(this._kv, this._secure);

  final KeyValueStorage _kv;
  final SecureStorage _secure;

  /// 清空键值存储（SharedPreferences）。
  Future<void> clearKeyValue() => _kv.clear();

  /// 清空安全存储（token 等）。
  Future<void> clearSecure() => _secure.deleteAll();

  /// 清空图片缓存（内存 + live）。
  void clearImageCache() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }

  /// 一键清理全部。
  Future<void> clearAll() async {
    await clearKeyValue();
    await clearSecure();
    clearImageCache();
  }
}
