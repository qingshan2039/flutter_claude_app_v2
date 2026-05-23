import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/core/responsive/orientation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('orientationsFor（纯映射）', () {
    test('portrait → up + down', () {
      expect(
        OrientationUtils.orientationsFor(OrientationLockMode.portrait),
        <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
    });

    test('landscape → left + right', () {
      expect(
        OrientationUtils.orientationsFor(OrientationLockMode.landscape),
        <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
    });

    test('all → 全部 4 个方向', () {
      expect(
        OrientationUtils.orientationsFor(OrientationLockMode.all),
        DeviceOrientation.values,
      );
    });
  });

  group('lock / unlock 调用 SystemChrome', () {
    final calls = <List<String>>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform,
              (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          calls.add(List<String>.from(call.arguments as List<dynamic>));
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('lockPortrait 发送 portrait 方向', () async {
      await OrientationUtils.lockPortrait();
      expect(calls.single, <String>[
        'DeviceOrientation.portraitUp',
        'DeviceOrientation.portraitDown',
      ]);
    });

    test('lockLandscape 发送 landscape 方向', () async {
      await OrientationUtils.lockLandscape();
      expect(calls.single, <String>[
        'DeviceOrientation.landscapeLeft',
        'DeviceOrientation.landscapeRight',
      ]);
    });

    test('unlock 发送全部 4 方向', () async {
      await OrientationUtils.unlock();
      expect(calls.single.length, 4);
    });
  });
}
