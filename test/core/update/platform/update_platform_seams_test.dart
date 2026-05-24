import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/core/update/platform/android_in_app_update.dart';
import 'package:flutter_claude_app_v2/core/update/platform/apk_updater.dart';
import 'package:flutter_claude_app_v2/core/update/platform/store_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

/// T23.3 / T23.4 / T23.5：平台更新接缝测试（channel mock + 优雅降级）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mock(MethodChannel channel, Future<Object?>? Function(MethodCall) handler) {
    messenger.setMockMethodCallHandler(channel, handler);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  }

  group('AndroidInAppUpdate (T23.3)', () {
    const impl = AndroidInAppUpdateImpl();

    test('checkAvailability：channel 返回 true → available', () async {
      mock(AndroidInAppUpdateImpl.channel, (call) async {
        expect(call.method, 'checkAvailability');
        return true;
      });
      expect(await impl.checkAvailability(), AndroidUpdateAvailability.available);
    });

    test('startImmediate/Flexible：转发到对应方法并返回结果', () async {
      final calls = <String>[];
      mock(AndroidInAppUpdateImpl.channel, (call) async {
        calls.add(call.method);
        return true;
      });
      expect(await impl.startImmediateUpdate(), isTrue);
      expect(await impl.startFlexibleUpdate(), isTrue);
      expect(calls, <String>['startImmediateUpdate', 'startFlexibleUpdate']);
    });

    test('无 handler（非 Android/测试）→ 优雅降级', () async {
      expect(await impl.checkAvailability(), AndroidUpdateAvailability.unknown);
      expect(await impl.startImmediateUpdate(), isFalse);
    });
  });

  group('StoreLauncher (T23.4)', () {
    const impl = StoreLauncherImpl();

    test('openStore：透传 url 并返回结果', () async {
      String? receivedUrl;
      mock(StoreLauncherImpl.channel, (call) async {
        expect(call.method, 'open');
        receivedUrl = (call.arguments as Map)['url'] as String?;
        return true;
      });
      expect(await impl.openStore('https://apps.apple.com/app/id1'), isTrue);
      expect(receivedUrl, 'https://apps.apple.com/app/id1');
    });

    test('无 handler → 返回 false', () async {
      expect(await impl.openStore('https://x'), isFalse);
    });
  });

  group('ApkUpdater (T23.5)', () {
    test('rangeHeaderFor：从已下载字节续传', () {
      expect(ApkUpdaterImpl.rangeHeaderFor(0), 'bytes=0-');
      expect(ApkUpdaterImpl.rangeHeaderFor(1048576), 'bytes=1048576-');
    });

    test('fileNameFromUrl：取末段、去 query、缺省回退', () {
      expect(
        ApkUpdaterImpl.fileNameFromUrl('https://x.com/a/app-release.apk'),
        'app-release.apk',
      );
      expect(
        ApkUpdaterImpl.fileNameFromUrl('https://x.com/a/app.apk?token=1'),
        'app.apk',
      );
      expect(ApkUpdaterImpl.fileNameFromUrl('https://x.com/'), 'update.apk');
    });

    test('installApk：无 handler → 优雅降级 false', () async {
      expect(await ApkUpdaterImpl().installApk('/tmp/x.apk'), isFalse);
    });

    test('installApk：channel 返回 true 且透传路径', () async {
      String? path;
      mock(ApkUpdaterImpl.channel, (call) async {
        expect(call.method, 'install');
        path = (call.arguments as Map)['path'] as String?;
        return true;
      });
      expect(await ApkUpdaterImpl().installApk('/tmp/app.apk'), isTrue);
      expect(path, '/tmp/app.apk');
    });
  });
}
