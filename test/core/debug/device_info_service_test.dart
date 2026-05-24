import 'package:flutter_claude_app_v2/core/debug/device_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceInfoService (T29.6)', () {
    test('snapshot 含操作系统/版本/App 版本等非空字段', () {
      const service = DeviceInfoService();
      final info = service.snapshot();

      expect(info['操作系统'], isNotEmpty);
      expect(info['系统版本'], isNotEmpty);
      expect(info['App 版本'], DeviceInfoService.appVersion);
      expect(info['CPU 核心数'], isNotEmpty);
      expect(info.keys, contains('Dart 版本'));
    });
  });
}
