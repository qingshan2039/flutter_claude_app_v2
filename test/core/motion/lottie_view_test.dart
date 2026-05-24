import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/motion/lottie_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LottieView (T34.4)', () {
    testWidgets('渲染占位 + autoplay/repeat 不抛异常', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LottieView(source: 'a.json'))),
      );
      await tester.pump(); // repeat 无限循环，不能 pumpAndSettle
      expect(find.byType(LottieView), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('autoplay=false & repeat=false 可静止（可 settle）', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieView(source: 'a.json', autoplay: false, repeat: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LottieView), findsOneWidget);
    });
  });
}
