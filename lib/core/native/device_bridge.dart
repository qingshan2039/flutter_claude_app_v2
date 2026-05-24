import 'package:flutter_claude_app_v2/core/native/method_channel_client.dart';
import 'package:injectable/injectable.dart';

/// 设备信息桥（T26.1 MethodChannel 示例）。
///
/// 演示**双向**：Dart 调原生取平台版本/电量；原生通过 [onNativePing] 回调 Dart。
/// 未接入原生 / 非移动端 / 测试环境下优雅降级（返回兜底值，不抛）。
///
/// 原生侧需在 `MainActivity.kt` / `AppDelegate` 注册同名 channel
/// `flutter_claude_app/device` 并实现 `getPlatformVersion` / `getBatteryLevel`，
/// 可主动 `invokeMethod("ping", ...)` 回调 Dart。
abstract class DeviceBridge {
  Future<String> platformVersion();
  Future<int> batteryLevel();

  /// 注册原生→Dart 的 `ping` 回调（双向）。
  void onNativePing(void Function(String message) handler);
}

@LazySingleton(as: DeviceBridge)
class DeviceBridgeImpl implements DeviceBridge {
  DeviceBridgeImpl() : _client = MethodChannelClient(channelName);

  /// 注入 client（测试用）。
  DeviceBridgeImpl.withClient(this._client);

  final MethodChannelClient _client;

  static const String channelName = 'flutter_claude_app/device';

  @override
  Future<String> platformVersion() =>
      _client.invokeOr<String>('getPlatformVersion', 'unknown');

  @override
  Future<int> batteryLevel() =>
      _client.invokeOr<int>('getBatteryLevel', -1);

  @override
  void onNativePing(void Function(String message) handler) {
    _client.setCallHandler((call) async {
      if (call.method == 'ping') {
        handler(call.arguments as String? ?? '');
      }
      return null;
    });
  }
}
