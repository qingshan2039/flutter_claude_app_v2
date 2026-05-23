import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/permission/app_permission.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

/// 统一权限服务（T09.1）。
///
/// 业务代码只与本抽象交互；不直接 import permission_handler。
/// 三态结果由 [AppPermissionStatus] 表达（granted / denied / permanentlyDenied + iOS 特例）。
///
/// 用法（T09.2 各权限示例）：
/// ```dart
/// final svc = getIt<PermissionService>();
/// final status = await svc.request(AppPermission.camera);
/// if (status.isGranted) {
///   // 打开相机
/// } else if (status.needsSettings) {
///   // 引导去系统设置（见 PermissionGuide，T09.3）
/// }
///
/// // 批量请求
/// final results = await svc.requestAll([
///   AppPermission.camera,
///   AppPermission.microphone,
/// ]);
/// ```
abstract class PermissionService {
  Future<AppPermissionStatus> request(AppPermission permission);
  Future<AppPermissionStatus> check(AppPermission permission);
  Future<Map<AppPermission, AppPermissionStatus>> requestAll(
    List<AppPermission> permissions,
  );

  /// 打开系统设置页（用户永久拒绝后引导）。返回是否成功打开。
  Future<bool> openSettings();
}

/// permission_handler 的薄封装（seam）。
///
/// 把对 permission_handler 静态 API 的依赖收敛到此接口，让 [PermissionServiceImpl]
/// 可用 fake gateway 做单元测试（permission_handler 依赖 platform channel，
/// 在 unit test 不可直接调用）。
abstract class PermissionGateway {
  Future<PermissionStatus> request(Permission permission);
  Future<PermissionStatus> status(Permission permission);
  Future<bool> openSettings();
}

/// 生产实现：直接调用 permission_handler。
@LazySingleton(as: PermissionGateway)
class PermissionHandlerGateway implements PermissionGateway {
  const PermissionHandlerGateway();

  @override
  Future<PermissionStatus> request(Permission permission) =>
      permission.request();

  @override
  Future<PermissionStatus> status(Permission permission) => permission.status;

  @override
  Future<bool> openSettings() => openAppSettings();
}

/// [PermissionService] 的实现：映射 [AppPermission] ↔ permission_handler [Permission]，
/// 并把 [PermissionStatus] 转回 [AppPermissionStatus]。
@LazySingleton(as: PermissionService)
class PermissionServiceImpl implements PermissionService {
  const PermissionServiceImpl(this._gateway);

  final PermissionGateway _gateway;

  @override
  Future<AppPermissionStatus> request(AppPermission permission) async {
    final status = await _gateway.request(mapToHandler(permission));
    return mapFromHandler(status);
  }

  @override
  Future<AppPermissionStatus> check(AppPermission permission) async {
    final status = await _gateway.status(mapToHandler(permission));
    return mapFromHandler(status);
  }

  @override
  Future<Map<AppPermission, AppPermissionStatus>> requestAll(
    List<AppPermission> permissions,
  ) async {
    final result = <AppPermission, AppPermissionStatus>{};
    for (final p in permissions) {
      result[p] = await request(p);
    }
    return result;
  }

  @override
  Future<bool> openSettings() => _gateway.openSettings();
}

/// [AppPermission] → permission_handler [Permission] 映射（T09.4 平台差异核心）。
///
/// permission_handler 内部已抹平多数 iOS/Android 差异（如 location → iOS whenInUse /
/// Android ACCESS_FINE_LOCATION）。本函数只需选对 [Permission] 常量。
@visibleForTesting
Permission mapToHandler(AppPermission permission) {
  return switch (permission) {
    AppPermission.camera => Permission.camera,
    AppPermission.photos => Permission.photos,
    AppPermission.microphone => Permission.microphone,
    AppPermission.location => Permission.location,
    AppPermission.notification => Permission.notification,
    AppPermission.storage => Permission.storage,
    AppPermission.bluetooth => Permission.bluetooth,
  };
}

/// permission_handler [PermissionStatus] → [AppPermissionStatus] 映射。
@visibleForTesting
AppPermissionStatus mapFromHandler(PermissionStatus status) {
  return switch (status) {
    PermissionStatus.granted => AppPermissionStatus.granted,
    PermissionStatus.denied => AppPermissionStatus.denied,
    PermissionStatus.permanentlyDenied => AppPermissionStatus.permanentlyDenied,
    PermissionStatus.restricted => AppPermissionStatus.restricted,
    PermissionStatus.limited => AppPermissionStatus.limited,
    // provisional（iOS 临时通知授权）视为已授予
    PermissionStatus.provisional => AppPermissionStatus.granted,
  };
}
