import 'package:flutter_claude_app_v2/core/permission/app_permission.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

/// Fake gateway：返回预设的 PermissionStatus，记录调用，避免触碰 platform channel。
class _FakeGateway implements PermissionGateway {
  _FakeGateway({this.statusToReturn = PermissionStatus.granted});

  PermissionStatus statusToReturn;
  final List<Permission> requested = <Permission>[];
  int openSettingsCount = 0;

  @override
  Future<PermissionStatus> request(Permission permission) async {
    requested.add(permission);
    return statusToReturn;
  }

  @override
  Future<PermissionStatus> status(Permission permission) async =>
      statusToReturn;

  @override
  Future<bool> openSettings() async {
    openSettingsCount++;
    return true;
  }
}

void main() {
  group('mapToHandler — AppPermission → Permission（覆盖 7 种）', () {
    test('每个 AppPermission 都映射到唯一 Permission', () {
      final mapping = <AppPermission, Permission>{
        for (final p in AppPermission.values) p: mapToHandler(p),
      };
      expect(mapping[AppPermission.camera], Permission.camera);
      expect(mapping[AppPermission.photos], Permission.photos);
      expect(mapping[AppPermission.microphone], Permission.microphone);
      expect(mapping[AppPermission.location], Permission.location);
      expect(mapping[AppPermission.notification], Permission.notification);
      expect(mapping[AppPermission.storage], Permission.storage);
      expect(mapping[AppPermission.bluetooth], Permission.bluetooth);
      // 7 种各不相同
      expect(mapping.values.toSet().length, 7);
    });
  });

  group('mapFromHandler — PermissionStatus → AppPermissionStatus', () {
    test('granted / denied / permanentlyDenied / restricted / limited', () {
      expect(mapFromHandler(PermissionStatus.granted),
          AppPermissionStatus.granted);
      expect(mapFromHandler(PermissionStatus.denied),
          AppPermissionStatus.denied);
      expect(mapFromHandler(PermissionStatus.permanentlyDenied),
          AppPermissionStatus.permanentlyDenied);
      expect(mapFromHandler(PermissionStatus.restricted),
          AppPermissionStatus.restricted);
      expect(mapFromHandler(PermissionStatus.limited),
          AppPermissionStatus.limited);
    });

    test('provisional → granted', () {
      expect(mapFromHandler(PermissionStatus.provisional),
          AppPermissionStatus.granted);
    });
  });

  group('AppPermissionStatusX 辅助', () {
    test('isGranted: granted 与 limited 都为 true', () {
      expect(AppPermissionStatus.granted.isGranted, isTrue);
      expect(AppPermissionStatus.limited.isGranted, isTrue);
      expect(AppPermissionStatus.denied.isGranted, isFalse);
    });

    test('needsSettings: permanentlyDenied 与 restricted 为 true', () {
      expect(AppPermissionStatus.permanentlyDenied.needsSettings, isTrue);
      expect(AppPermissionStatus.restricted.needsSettings, isTrue);
      expect(AppPermissionStatus.denied.needsSettings, isFalse);
      expect(AppPermissionStatus.granted.needsSettings, isFalse);
    });
  });

  group('PermissionServiceImpl', () {
    test('request 委托 gateway 并转换状态', () async {
      final gateway = _FakeGateway();
      final service = PermissionServiceImpl(gateway);

      final status = await service.request(AppPermission.camera);

      expect(status, AppPermissionStatus.granted);
      expect(gateway.requested.single, Permission.camera);
    });

    test('check 走 gateway.status', () async {
      final gateway =
          _FakeGateway(statusToReturn: PermissionStatus.permanentlyDenied);
      final service = PermissionServiceImpl(gateway);

      final status = await service.check(AppPermission.location);
      expect(status, AppPermissionStatus.permanentlyDenied);
    });

    test('requestAll 返回每个权限的状态', () async {
      final gateway = _FakeGateway(statusToReturn: PermissionStatus.denied);
      final service = PermissionServiceImpl(gateway);

      final results = await service.requestAll(<AppPermission>[
        AppPermission.camera,
        AppPermission.microphone,
        AppPermission.notification,
      ]);

      expect(results.length, 3);
      expect(results[AppPermission.camera], AppPermissionStatus.denied);
      expect(results[AppPermission.microphone], AppPermissionStatus.denied);
      expect(gateway.requested.length, 3);
    });

    test('openSettings 委托 gateway', () async {
      final gateway = _FakeGateway();
      final service = PermissionServiceImpl(gateway);

      final ok = await service.openSettings();
      expect(ok, isTrue);
      expect(gateway.openSettingsCount, 1);
    });
  });
}
