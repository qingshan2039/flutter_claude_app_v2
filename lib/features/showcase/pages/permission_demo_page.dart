import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/permission/app_permission.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_guide.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_service.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M09 权限管理 — 可视化演示（真机/模拟器请求权限）。
class PermissionDemoPage extends StatefulWidget {
  const PermissionDemoPage({super.key});

  @override
  State<PermissionDemoPage> createState() => _PermissionDemoPageState();
}

class _PermissionDemoPageState extends State<PermissionDemoPage> {
  final PermissionService _service = getIt<PermissionService>();
  late final PermissionGuide _guide = PermissionGuide(_service);
  final Map<AppPermission, AppPermissionStatus> _status =
      <AppPermission, AppPermissionStatus>{};

  Future<void> _request(AppPermission permission) async {
    final status = await _service.request(permission);
    setState(() => _status[permission] = status);

    // 永久拒绝 → 引导去系统设置
    if (status.needsSettings && mounted) {
      await PermissionGuide.showSettingsDialog(
        context,
        title: '需要${_label(permission)}权限',
        message: '该权限已被永久拒绝，请到系统设置中开启。',
        service: _service,
      );
    }
  }

  String _label(AppPermission p) => switch (p) {
        AppPermission.camera => '相机',
        AppPermission.photos => '相册',
        AppPermission.microphone => '麦克风',
        AppPermission.location => '定位',
        AppPermission.notification => '通知',
        AppPermission.storage => '存储',
        AppPermission.bluetooth => '蓝牙',
      };

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: '权限管理',
      moduleId: 'M09',
      children: <Widget>[
        DemoSection(
          title: '请求权限（真机/模拟器有效）',
          description: '点「请求」弹原生授权框；永久拒绝会引导去系统设置',
          child: Column(
            children: <Widget>[
              for (final p in AppPermission.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_label(p)),
                  subtitle: Text(_status[p]?.name ?? '未请求'),
                  // 主题给按钮设了最小宽度无限（整宽按钮）。ListTile 以无界宽度
                  // 测量 trailing，必须用本地 style 覆盖 minimumSize 才不会触发
                  // “infinite width” 断言。
                  trailing: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => _request(p),
                    child: const Text('请求'),
                  ),
                ),
            ],
          ),
        ),
        DemoSection(
          title: '一站式 ensureGranted',
          description: '请求 → 已授予返回 true；永久拒绝自动弹引导',
          child: FilledButton.tonal(
            onPressed: () async {
              final ok = await _guide.ensureGranted(
                context,
                AppPermission.camera,
                rationaleTitle: '需要相机权限',
                rationaleMessage: '用于拍照与扫码，请在设置中开启。',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('camera granted = $ok')),
                );
              }
            },
            child: const Text('ensureGranted(camera)'),
          ),
        ),
      ],
    );
  }
}
