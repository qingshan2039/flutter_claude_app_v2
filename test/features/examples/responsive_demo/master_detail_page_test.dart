import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/features/examples/responsive_demo/master_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setSize(WidgetTester tester, double width) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('窄屏（mobile）', () {
    testWidgets('单栏列表，无 NavigationRail', (tester) async {
      await setSize(tester, 400);
      await tester.pumpWidget(const MaterialApp(home: MasterDetailPage(itemCount: 5)));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('点列表项 push 详情页', (tester) async {
      await setSize(tester, 400);
      await tester.pumpWidget(const MaterialApp(home: MasterDetailPage(itemCount: 5)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();

      expect(find.text('Detail of item 2'), findsOneWidget);
    });
  });

  group('宽屏（tablet+）', () {
    testWidgets('NavigationRail + 列表 + 详情并排', (tester) async {
      await setSize(tester, 1200);
      await tester.pumpWidget(const MaterialApp(home: MasterDetailPage(itemCount: 5)));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      // 默认选中 0 → 详情显示 item 0
      expect(find.text('Detail of item 0'), findsOneWidget);
    });

    testWidgets('点列表项即时更新右侧详情（不跳转）', (tester) async {
      await setSize(tester, 1200);
      await tester.pumpWidget(const MaterialApp(home: MasterDetailPage(itemCount: 5)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Item 3'));
      await tester.pumpAndSettle();

      expect(find.text('Detail of item 3'), findsOneWidget);
      // 仍在同一页（NavigationRail 还在）
      expect(find.byType(NavigationRail), findsOneWidget);
    });
  });
}
