import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell 路由的外壳 Scaffold（T07.3）。
///
/// 用 [StatefulShellRoute.indexedStack] 时，go_router 把当前活跃 branch 的 widget
/// 作为 [navigationShell] 传进来；本组件只负责画 [BottomNavigationBar]，让用户
/// 在三个 branch（home / search / settings）之间切换。
///
/// branch 切换通过 [StatefulNavigationShell.goBranch] 完成，自动保留各 branch
/// 内部的导航栈状态。
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // 再次点击当前 tab 时回到 branch 根
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
