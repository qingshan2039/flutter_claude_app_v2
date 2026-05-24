import 'package:flutter_claude_app_v2/core/native/pigeon/native_messages.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// T26.3：验证 Pigeon 生成的类型安全通信代码可用（编译 + API 表面存在）。
void main() {
  group('Pigeon 生成代码 (T26.3)', () {
    test('DeviceDetails 数据类持有字段', () {
      final details = DeviceDetails(
        osName: 'Android',
        osVersion: '14',
        model: 'Pixel 8',
        isPhysicalDevice: true,
      );
      expect(details.osName, 'Android');
      expect(details.osVersion, '14');
      expect(details.model, 'Pixel 8');
      expect(details.isPhysicalDevice, isTrue);
    });

    test('HostApi 客户端 NativeDeviceApi 可实例化（类型安全）', () {
      expect(NativeDeviceApi.new, isNotNull);
      expect(NativeDeviceApi(), isA<NativeDeviceApi>());
    });
  });
}
