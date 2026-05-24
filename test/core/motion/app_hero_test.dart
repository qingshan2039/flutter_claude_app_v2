import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/motion/app_hero.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppHero (T34.3)', () {
    testWidgets('enabled 包裹 Hero', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppHero(tag: 't', child: Text('x'))),
        ),
      );
      expect(find.byType(Hero), findsOneWidget);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('enabled=false 直接渲染 child（无 Hero）', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppHero(tag: 't', enabled: false, child: Text('x')),
          ),
        ),
      );
      expect(find.byType(Hero), findsNothing);
      expect(find.text('x'), findsOneWidget);
    });
  });
}
