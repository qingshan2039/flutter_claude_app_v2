import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M07 路由管理 — 可视化演示。
///
/// 注：完整 go_router（Shell + 守卫 + 404 + 类型安全）在 `main.dart` 主入口；
/// 本页用 Navigator 演示「参数传递 + 自定义转场」效果（showcase 用 MaterialApp，
/// 不含 go_router 树）。
class RoutingDemoPage extends StatelessWidget {
  const RoutingDemoPage({super.key});

  void _pushFade(BuildContext context, String id) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: MotionTokens.normal,
        pageBuilder: (_, _, _) => _DetailPage(id: id),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _pushSlide(BuildContext context, String id) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: MotionTokens.normal,
        pageBuilder: (_, _, _) => _DetailPage(id: id),
        transitionsBuilder: (_, animation, _, child) {
          final tween = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: MotionTokens.emphasizedDecelerate));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: '路由管理',
      moduleId: 'M07',
      children: <Widget>[
        DemoSection(
          title: '参数传递 + 自定义转场',
          description: '点按钮 push 详情页（带 id 参数），观察转场动画',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: () => _pushFade(context, '42'),
                child: const Text('Fade → 详情 #42'),
              ),
              FilledButton.tonal(
                onPressed: () => _pushSlide(context, '99'),
                child: const Text('SlideUp → 详情 #99'),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '完整 go_router 能力',
          description: '主入口（lib/main.dart）的完整路由栈',
          child: Text('• StatefulShellRoute 底部导航（home/search/settings）\n'
              '• 路由守卫 redirect（未登录跳 /login）\n'
              '• errorBuilder 404 页\n'
              '• 类型安全路由（go_router_builder \$DetailRoute）\n'
              '• RouterLogObserver 路由日志\n'
              '运行 `flutter run`（默认入口）体验完整路由。'),
        ),
      ],
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail #$id')),
      body: Center(
        child: Text(
          '收到路由参数 id=$id',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
