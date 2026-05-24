import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/core/native/battery_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  group('BatteryMonitor (T26.2)', () {
    test('EventChannel 推送的事件被映射为 Stream<int>', () async {
      messenger.setMockStreamHandler(
        const EventChannel(BatteryMonitorImpl.channelName),
        MockStreamHandler.inline(
          onListen: (arguments, sink) {
            sink
              ..success(88)
              ..success(77)
              ..endOfStream();
          },
        ),
      );
      addTearDown(
        () => messenger.setMockStreamHandler(
          const EventChannel(BatteryMonitorImpl.channelName),
          null,
        ),
      );

      final monitor = BatteryMonitorImpl();
      expect(await monitor.levelStream.toList(), <int>[88, 77]);
    });

    test('未实现（无 handler）→ 静默降级，不抛 MissingPlugin', () async {
      final monitor = BatteryMonitorImpl();
      // 监听后立即取消；不应抛出未捕获异常。
      final sub = monitor.levelStream.listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
    });
  });
}
