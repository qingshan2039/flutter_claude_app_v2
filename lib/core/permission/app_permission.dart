import 'package:flutter_claude_app_v2/core/permission/permission_service.dart' show PermissionService;

/// 应用层权限枚举（T09.1 / T09.2）。
///
/// 这是**平台无关**的抽象：业务代码只认 [AppPermission]，由 [PermissionService]
/// 内部映射到 permission_handler 的平台权限（iOS / Android 名称差异在那里抹平）。
enum AppPermission {
  camera,
  photos,
  microphone,
  location,
  notification,
  storage,
  bluetooth,
}

/// 权限状态三态（+ iOS 特有 restricted / limited）。
///
/// spec 要求 granted / denied / permanentlyDenied 三态；这里额外保留：
/// - [restricted]：iOS 家长控制 / MDM 限制（不可由用户授予）
/// - [limited]：iOS 14+ 相册「仅选中照片」部分授权
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

extension AppPermissionStatusX on AppPermissionStatus {
  /// limited（部分授权）也视为「可用」。
  bool get isGranted =>
      this == AppPermissionStatus.granted ||
      this == AppPermissionStatus.limited;

  bool get isDenied => this == AppPermissionStatus.denied;

  /// permanentlyDenied / restricted 都需要引导用户去系统设置（无法再次弹窗）。
  bool get needsSettings =>
      this == AppPermissionStatus.permanentlyDenied ||
      this == AppPermissionStatus.restricted;
}
