import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/native/battery_monitor.dart';
import 'package:flutter_claude_app_v2/core/native/device_bridge.dart';
import 'package:flutter_claude_app_v2/core/native/native_platform_view.dart';
import 'package:flutter_claude_app_v2/core/native/pigeon/native_messages.g.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M26 原生互操作 demo：MethodChannel + EventChannel + Pigeon + PlatformView。
///
/// 本机/未接入原生时各通道优雅降级（显示「未接入」），真机接入原生后即生效。
class NativeDemoPage extends StatefulWidget {
  const NativeDemoPage({super.key});

  @override
  State<NativeDemoPage> createState() => _NativeDemoPageState();
}

class _NativeDemoPageState extends State<NativeDemoPage> {
  final DeviceBridge _device = getIt<DeviceBridge>();
  late final Stream<int> _batteryStream = getIt<BatteryMonitor>().levelStream;

  String _mcResult = '（未调用）';
  String _pigeonResult = '（未调用）';
  bool _showPlatformView = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      moduleId: 'M26',
      title: '原生互操作',
      children: <Widget>[
        DemoSection(
          title: 'MethodChannel（T26.1）',
          description: 'Dart↔原生双向调用 + 错误归一化；未接入时降级。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('结果', _mcResult),
              const SizedBox(height: SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                children: <Widget>[
                  FilledButton(
                    onPressed: _callPlatformVersion,
                    child: const Text('getPlatformVersion'),
                  ),
                  FilledButton.tonal(
                    onPressed: _callBatteryLevel,
                    child: const Text('getBatteryLevel'),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'EventChannel（T26.2）',
          description: '原生持续推送的事件流（电量），封装为 Stream<int>。',
          child: StreamBuilder<int>(
            stream: _batteryStream,
            builder: (context, snapshot) {
              final text = snapshot.hasData
                  ? '电量：${snapshot.data}%'
                  : '等待原生事件…（未接入原生时无数据）';
              return DemoResultRow('电量事件', text);
            },
          ),
        ),
        DemoSection(
          title: 'Pigeon（T26.3）',
          description: '类型安全通信（代码生成）：无需手写 channel/序列化。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('结果', _pigeonResult),
              const SizedBox(height: SpacingTokens.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: _callPigeon,
                  child: const Text('NativeDeviceApi.getDeviceDetails'),
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'PlatformView（T26.4）',
          description: '嵌入原生视图；需原生注册 viewType（按需加载演示）。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_showPlatformView)
                const SizedBox(
                  height: 120,
                  child: NativePlatformView(
                    viewType: 'm26_demo_view',
                    fallback: ColoredBox(
                      color: Color(0x11000000),
                      child: Center(child: Text('原生视图占位')),
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showPlatformView = true),
                    child: const Text('加载原生视图'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _callPlatformVersion() async {
    final v = await _device.platformVersion();
    setState(() => _mcResult = 'platformVersion = $v');
  }

  Future<void> _callBatteryLevel() async {
    final level = await _device.batteryLevel();
    setState(
      () => _mcResult = level < 0 ? '电量不可用（未接入）' : '电量 = $level%',
    );
  }

  Future<void> _callPigeon() async {
    try {
      final details = await NativeDeviceApi().getDeviceDetails();
      setState(
        () => _pigeonResult =
            '${details.osName ?? "?"} ${details.osVersion ?? ""} '
            '${details.model ?? ""}',
      );
    } on Object catch (e) {
      setState(() => _pigeonResult = '类型安全调用（原生未接入）：$e');
    }
  }
}
