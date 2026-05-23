import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/responsive/breakpoints.dart';
import 'package:flutter_claude_app_v2/core/responsive/responsive_builder.dart';
import 'package:flutter_claude_app_v2/core/responsive/safe_area_utils.dart';
import 'package:flutter_claude_app_v2/features/examples/responsive_demo/master_detail_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M12 多屏幕适配 — 可视化演示（旋转设备 / 拖窗口看变化）。
class ResponsiveDemoPage extends StatelessWidget {
  const ResponsiveDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final type = context.screenType;

    return DemoScaffold(
      title: '多屏幕适配',
      moduleId: 'M12',
      children: <Widget>[
        DemoSection(
          title: '当前断点（旋转/拖窗口实时变化）',
          child: Column(
            children: <Widget>[
              DemoResultRow('宽 × 高', '${size.width.toStringAsFixed(0)} × ${size.height.toStringAsFixed(0)}'),
              DemoResultRow('ScreenType', type.name),
              DemoResultRow('isTabletOrLarger', '${context.isTabletOrLarger}'),
            ],
          ),
        ),
        DemoSection(
          title: 'ResponsiveBuilder（按父约束选布局）',
          description: '同一组件在不同宽度渲染不同内容',
          child: SizedBox(
            height: 60,
            child: ResponsiveBuilder(
              mobile: (_) => _box('MOBILE 单列', Colors.blue),
              tablet: (_) => _box('TABLET 双列', Colors.green),
              desktop: (_) => _box('DESKTOP 多列', Colors.deepPurple),
            ),
          ),
        ),
        DemoSection(
          title: '安全区域 inset',
          child: Column(
            children: <Widget>[
              DemoResultRow('top inset', '${SafeAreaUtils.topInset(context)}'),
              DemoResultRow('bottom inset', '${SafeAreaUtils.bottomInset(context)}'),
              DemoResultRow(
                  'Home Indicator', '${SafeAreaUtils.hasBottomIndicator(context)}'),
            ],
          ),
        ),
        DemoSection(
          title: '平板 Master-Detail',
          description: '窄屏单栏 push 详情；宽屏 NavigationRail + 双栏',
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MasterDetailPage(),
              ),
            ),
            child: const Text('打开 Master-Detail 示例'),
          ),
        ),
      ],
    );
  }

  Widget _box(String label, Color color) => Container(
        color: color.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      );
}
