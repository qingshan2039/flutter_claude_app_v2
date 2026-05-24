import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/motion/app_transitions.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTransitions (T34.2)', () {
    const anim = AlwaysStoppedAnimation<double>(1);

    testWidgets('每种类型构建对应过渡 widget', (tester) async {
      // 用裸 Directionality 而非 MaterialApp，避免页面路由自带的默认转场
      // （Flutter 安卓默认转场含多个 SlideTransition）污染计数。
      Future<void> pumpType(AppTransitionType type) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AppTransitions.build(type, anim, const Text('hi')),
        ),
      );

      await pumpType(AppTransitionType.fade);
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsNothing);

      await pumpType(AppTransitionType.slideUp);
      expect(find.byType(SlideTransition), findsOneWidget);

      await pumpType(AppTransitionType.scale);
      expect(find.byType(ScaleTransition), findsOneWidget);

      await pumpType(AppTransitionType.sharedAxis);
      expect(find.byType(SlideTransition), findsOneWidget);
    });

    test('route 默认时长 = MotionTokens.normal', () {
      final route = AppTransitions.route<void>(builder: (_) => const SizedBox());
      expect((route as PageRoute<void>).transitionDuration, MotionTokens.normal);
    });

    testWidgets('route 推入目标页', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    AppTransitions.route<void>(
                      type: AppTransitionType.scale,
                      builder: (_) => const Scaffold(body: Text('详情页')),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('详情页'), findsOneWidget);
    });
  });
}
