import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// 电量监听（T26.2 EventChannel 示例）。
///
/// 把原生持续推送的事件流（如电量、网络变化）封装成类型安全的 `Stream<int>`。
/// 原生侧需注册 EventChannel `flutter_claude_app/battery_stream`，在
/// `onListen` 时持续 `sink.success(level)`。未接入/非移动端/测试环境下，
/// `MissingPluginException` 被吞掉（流不发值，不崩溃）。
abstract class BatteryMonitor {
  /// 电量百分比事件流（0–100；解析失败为 -1）。
  Stream<int> get levelStream;
}

@LazySingleton(as: BatteryMonitor)
class BatteryMonitorImpl implements BatteryMonitor {
  BatteryMonitorImpl() : _channel = const EventChannel(channelName);

  /// 注入 channel（测试用）。
  BatteryMonitorImpl.withChannel(this._channel);

  final EventChannel _channel;

  static const String channelName = 'flutter_claude_app/battery_stream';

  @override
  Stream<int> get levelStream => _channel
      .receiveBroadcastStream()
      .map<int>(
        (event) => event is int ? event : int.tryParse('$event') ?? -1,
      )
      // 平台未实现时静默降级（流不发值）。
      .handleError(
        (_) {},
        test: (e) => e is MissingPluginException,
      );
}
