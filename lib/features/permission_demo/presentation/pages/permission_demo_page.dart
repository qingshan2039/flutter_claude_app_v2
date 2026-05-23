import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/permission/app_permission.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_guide.dart';
import 'package:flutter_claude_app_v2/core/permission/permission_service.dart';

/// 权限演示页（T19.5）：逐权限请求 + 永久拒绝引导到系统设置。
///
/// 复用 M09 的 [PermissionService] / [PermissionGuide]。真机/模拟器上点「请求」
/// 会弹原生授权框；被永久拒绝时弹引导对话框跳系统设置。
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
    return Scaffold(
      appBar: AppBar(title: const Text('权限演示')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('逐权限请求', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final p in AppPermission.values)
            Card(
              child: ListTile(
                title: Text(_label(p)),
                subtitle: Text(_status[p]?.name ?? '未请求'),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () => _request(p),
                  child: const Text('请求'),
                ),
              ),
            ),
          const Divider(height: 32),
          Text('一站式 ensureGranted', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _ensureCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('确保相机权限（含永久拒绝引导）'),
          ),
        ],
      ),
    );
  }

  Future<void> _ensureCamera() async {
    final ok = await _guide.ensureGranted(
      context,
      AppPermission.camera,
      rationaleTitle: '需要相机权限',
      rationaleMessage: '用于拍照与扫码，请在设置中开启。',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('camera granted = $ok')),
      );
    }
  }
}
