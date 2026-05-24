import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Android in-app update 可用性。
enum AndroidUpdateAvailability {
  /// 无法判断（非 Android / 未实现 / 出错）。
  unknown,

  /// 当前无可用更新。
  notAvailable,

  /// 有可用更新，可发起 in-app update 流程。
  available,
}

/// Android 应用内更新（T23.3）。
///
/// 封装 Google Play Core 的 in-app update：
/// - **immediate（强制）**：全屏阻塞式更新页，适合强制更新。
/// - **flexible（灵活）**：后台下载，下载完成后提示重启，适合可选更新。
///
/// 真实实现：在原生侧接入 Play Core（或用 `in_app_update` 包），通过
/// MethodChannel `flutter_claude_app/in_app_update` 暴露下列方法。非 Android /
/// 未接入 / 测试环境下**优雅降级**（不抛异常）。
abstract class AndroidInAppUpdate {
  Future<AndroidUpdateAvailability> checkAvailability();

  /// 发起 immediate（强制）更新流程，返回是否成功启动。
  Future<bool> startImmediateUpdate();

  /// 发起 flexible（灵活/后台）更新流程，返回是否成功启动。
  Future<bool> startFlexibleUpdate();
}

@LazySingleton(as: AndroidInAppUpdate)
class AndroidInAppUpdateImpl implements AndroidInAppUpdate {
  const AndroidInAppUpdateImpl();

  static const MethodChannel channel = MethodChannel(
    'flutter_claude_app/in_app_update',
  );

  @override
  Future<AndroidUpdateAvailability> checkAvailability() async {
    try {
      final available = await channel.invokeMethod<bool>('checkAvailability');
      return (available ?? false)
          ? AndroidUpdateAvailability.available
          : AndroidUpdateAvailability.notAvailable;
    } on MissingPluginException {
      return AndroidUpdateAvailability.unknown; // 非 Android / 未接入 / 测试
    } on PlatformException {
      return AndroidUpdateAvailability.unknown;
    }
  }

  @override
  Future<bool> startImmediateUpdate() => _start('startImmediateUpdate');

  @override
  Future<bool> startFlexibleUpdate() => _start('startFlexibleUpdate');

  Future<bool> _start(String method) async {
    try {
      final ok = await channel.invokeMethod<bool>(method);
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
