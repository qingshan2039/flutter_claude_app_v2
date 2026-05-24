import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/core/native/device_bridge.dart';
import 'package:flutter_claude_app_v2/core/native/method_channel_client.dart';
import 'package:flutter_claude_app_v2/core/native/native_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mock(MethodChannel channel, Future<Object?>? Function(MethodCall) h) {
    messenger.setMockMethodCallHandler(channel, h);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  }

  group('MethodChannelClient (T26.1)', () {
    test('invoke：正常返回', () async {
      final client = MethodChannelClient('test/mc');
      mock(client.channel, (call) async => 'hi:${call.arguments}');
      expect(await client.invoke<String>('echo', 'x'), 'hi:x');
    });

    test('invoke：PlatformException → NativeCallException(code)', () async {
      final client = MethodChannelClient('test/mc');
      mock(
        client.channel,
        (_) async => throw PlatformException(code: 'E1', message: 'bad'),
      );
      expect(
        () => client.invoke<void>('boom'),
        throwsA(
          isA<NativeCallException>().having((e) => e.code, 'code', 'E1'),
        ),
      );
    });

    test('invoke：无 handler → NativeUnavailableException', () async {
      final client = MethodChannelClient('test/none');
      expect(
        () => client.invoke<void>('x'),
        throwsA(isA<NativeUnavailableException>()),
      );
    });

    test('invokeOr：不可用/出错返回兜底', () async {
      final client = MethodChannelClient('test/none');
      expect(await client.invokeOr<int>('x', -1), -1);
    });
  });

  group('DeviceBridge 双向 (T26.1)', () {
    test('Dart→原生：platformVersion / batteryLevel', () async {
      mock(const MethodChannel(DeviceBridgeImpl.channelName), (call) async {
        if (call.method == 'getPlatformVersion') return 'Android 14';
        if (call.method == 'getBatteryLevel') return 87;
        return null;
      });
      final bridge = DeviceBridgeImpl();
      expect(await bridge.platformVersion(), 'Android 14');
      expect(await bridge.batteryLevel(), 87);
    });

    test('Dart→原生：未实现时降级（unknown / -1）', () async {
      final bridge = DeviceBridgeImpl();
      expect(await bridge.platformVersion(), 'unknown');
      expect(await bridge.batteryLevel(), -1);
    });

    test('原生→Dart：onNativePing 回调收到消息', () async {
      final bridge = DeviceBridgeImpl();
      String? received;
      bridge.onNativePing((m) => received = m);

      // 模拟原生主动调用 ping。
      await messenger.handlePlatformMessage(
        DeviceBridgeImpl.channelName,
        const StandardMethodCodec()
            .encodeMethodCall(const MethodCall('ping', 'hello-from-native')),
        (_) {},
      );
      expect(received, 'hello-from-native');
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          const MethodChannel(DeviceBridgeImpl.channelName),
          null,
        ),
      );
    });
  });
}
