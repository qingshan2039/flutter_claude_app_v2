import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/permission/app_permission.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_service.dart';

/// 永久拒绝引导工具（T09.3）。
///
/// 当权限 [AppPermissionStatus.needsSettings]（permanentlyDenied / restricted）时，
/// 系统不会再弹原生授权框；只能引导用户去「系统设置」手动开启。本工具提供：
/// - [showSettingsDialog]：二次说明弹窗（解释为什么需要 + 跳设置按钮）
/// - [ensureGranted]：一站式流程（请求 → 若永久拒绝则弹引导）
class PermissionGuide {
  const PermissionGuide(this._service);

  final PermissionService _service;

  /// 弹出「二次说明 + 去设置」对话框。
  ///
  /// 返回 true 表示用户点了「去设置」（并已调用 openSettings）；false 表示取消。
  static Future<bool> showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
    required PermissionService service,
    String cancelText = 'Not now',
    String settingsText = 'Open settings',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(settingsText),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await service.openSettings();
      return true;
    }
    return false;
  }

  /// 一站式：请求权限 → 已授予返回 true；永久拒绝则弹引导对话框。
  ///
  /// 返回 true 表示已授权（或用户被引导到设置；调用方应在返回前台后重新 check）。
  Future<bool> ensureGranted(
    BuildContext context,
    AppPermission permission, {
    required String rationaleTitle,
    required String rationaleMessage,
  }) async {
    final status = await _service.request(permission);
    if (status.isGranted) {
      return true;
    }
    if (status.needsSettings && context.mounted) {
      await showSettingsDialog(
        context,
        title: rationaleTitle,
        message: rationaleMessage,
        service: _service,
      );
    }
    return false;
  }
}
