import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/page_transitions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  GoRouter buildRouter(Page<dynamic> Function(BuildContext, GoRouterState) pageBuilder) {
    return GoRouter(
      initialLocation: '/a',
      routes: <RouteBase>[
        GoRoute(
          path: '/a',
          builder: (context, state) => const Scaffold(body: Text('A')),
        ),
        GoRoute(path: '/b', pageBuilder: pageBuilder),
      ],
    );
  }

  testWidgets('fade transition 在 push 过程中产生 0→1 opacity 动画', (tester) async {
    final router = buildRouter(
      (context, state) => PageTransitions.fade<void>(
        state: state,
        child: const Scaffold(body: Text('B')),
      ),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/b');
    await tester.pump();              // 启动动画
    await tester.pump(const Duration(milliseconds: 50));
    // 动画进行中，FadeTransition 在 widget 树
    expect(find.byType(FadeTransition), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('slideUp transition 产生 SlideTransition', (tester) async {
    final router = buildRouter(
      (context, state) => PageTransitions.slideUp<void>(
        state: state,
        child: const Scaffold(body: Text('B')),
      ),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/b');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(SlideTransition), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('scale transition 产生 ScaleTransition + FadeTransition 组合', (tester) async {
    final router = buildRouter(
      (context, state) => PageTransitions.scale<void>(
        state: state,
        child: const Scaffold(body: Text('B')),
      ),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/b');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ScaleTransition), findsWidgets);
    expect(find.byType(FadeTransition), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
  });

  test('CustomTransitionPage 自动从 state.pageKey 取 key（避免重复跳转重建）', () {
    final state = GoRouterState(
      _DummyConfig(),
      uri: Uri.parse('/b'),
      matchedLocation: '/b',
      name: null,
      path: '/b',
      fullPath: '/b',
      pathParameters: const <String, String>{},
      pageKey: const ValueKey<String>('test-key'),
      error: null,
    );

    final page = PageTransitions.fade<void>(
      state: state,
      child: const Text('x'),
    );

    expect(page.key, const ValueKey<String>('test-key'));
  });
}

class _DummyConfig implements RouteConfiguration {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
