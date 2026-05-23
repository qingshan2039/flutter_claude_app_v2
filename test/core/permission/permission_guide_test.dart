import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/permission/app_permission.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_guide.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake service：可控返回状态 + 记录 openSettings 调用。
class _FakeService implements PermissionService {
  _FakeService(this._status);
  final AppPermissionStatus _status;
  int openSettingsCount = 0;

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async =>
      _status;
  @override
  Future<AppPermissionStatus> check(AppPermission permission) async => _status;
  @override
  Future<Map<AppPermission, AppPermissionStatus>> requestAll(
    List<AppPermission> permissions,
  ) async =>
      {for (final p in permissions) p: _status};
  @override
  Future<bool> openSettings() async {
    openSettingsCount++;
    return true;
  }
}

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PermissionGuide.showSettingsDialog', () {
    testWidgets('点「Open settings」调用 openSettings 并返回 true', (tester) async {
      final service = _FakeService(AppPermissionStatus.permanentlyDenied);
      late bool result;

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await PermissionGuide.showSettingsDialog(
                  context,
                  title: 'Camera needed',
                  message: 'Enable camera in settings.',
                  service: service,
                );
              },
              child: const Text('go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.text('Camera needed'), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(service.openSettingsCount, 1);
    });

    testWidgets('点「Not now」不调用 openSettings 返回 false', (tester) async {
      final service = _FakeService(AppPermissionStatus.permanentlyDenied);
      late bool result;

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await PermissionGuide.showSettingsDialog(
                  context,
                  title: 'Camera needed',
                  message: 'Enable camera in settings.',
                  service: service,
                );
              },
              child: const Text('go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(service.openSettingsCount, 0);
    });
  });

  group('PermissionGuide.ensureGranted', () {
    testWidgets('已授予 → 返回 true，不弹对话框', (tester) async {
      final service = _FakeService(AppPermissionStatus.granted);
      final guide = PermissionGuide(service);
      late bool result;

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await guide.ensureGranted(
                  context,
                  AppPermission.camera,
                  rationaleTitle: 'T',
                  rationaleMessage: 'M',
                );
              },
              child: const Text('go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('T'), findsNothing); // 无对话框
    });

    testWidgets('永久拒绝 → 返回 false 并弹引导对话框', (tester) async {
      final service = _FakeService(AppPermissionStatus.permanentlyDenied);
      final guide = PermissionGuide(service);
      late bool result;

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await guide.ensureGranted(
                  context,
                  AppPermission.camera,
                  rationaleTitle: 'Camera needed',
                  rationaleMessage: 'Enable in settings',
                );
              },
              child: const Text('go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.text('Camera needed'), findsOneWidget); // 弹了对话框
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(result, isFalse); // ensureGranted 在未授予时返回 false
      expect(service.openSettingsCount, 1);
    });
  });
}
