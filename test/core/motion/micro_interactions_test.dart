import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/motion/micro_interactions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TapScale (T34.5)', () {
    testWidgets('点击触发 onTap，按下时缩放', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TapScale(
                onTap: () => tapped = true,
                child: const Text('btn'),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedScale), findsOneWidget);
      await tester.tap(find.text('btn'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('AppearAnimation (T34.5)', () {
    testWidgets('渲染子组件（淡入上滑）', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppearAnimation(child: Text('item'))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('item'), findsOneWidget);
      expect(find.byType(FadeTransition), findsWidgets);
    });
  });
}
