import 'package:flutter_claude_app_v2/core/security/device_integrity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const service = DeviceIntegrityServiceImpl();

  group('DeviceIntegrityServiceImpl (T18.5)', () {
    tearDown(() {
      messenger.setMockMethodCallHandler(
        DeviceIntegrityServiceImpl.channel,
        null,
      );
    });

    test('解析原生返回的 map', () async {
      messenger.setMockMethodCallHandler(
        DeviceIntegrityServiceImpl.channel,
        (call) async => <String, dynamic>{
          'isRootedOrJailbroken': true,
          'isEmulator': true,
          'isDebuggable': false,
        },
      );

      final report = await service.check();

      expect(report.isRootedOrJailbroken, isTrue);
      expect(report.isEmulator, isTrue);
      expect(report.isDebuggable, isFalse);
      expect(report.isTrusted, isFalse);
    });

    test('无原生 handler → 默认「可信」报告（不误杀）', () async {
      messenger.setMockMethodCallHandler(
        DeviceIntegrityServiceImpl.channel,
        null,
      );

      final report = await service.check();

      expect(report.isRootedOrJailbroken, isFalse);
      expect(report.isTrusted, isTrue);
    });
  });

  group('DeviceIntegrityReport', () {
    test('fromMap 缺字段时取默认（可信）', () {
      final report = DeviceIntegrityReport.fromMap(const <String, dynamic>{});
      expect(report.isTrusted, isTrue);
      expect(report.isEmulator, isFalse);
    });
  });
}
