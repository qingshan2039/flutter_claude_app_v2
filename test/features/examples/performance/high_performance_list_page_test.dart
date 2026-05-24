import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/features/examples/performance/high_performance_list_page.dart';
import 'package:flutter_test/flutter_test.dart';

/// T21.3：高性能长列表示例 widget 测试。
void main() {
  group('HighPerformanceListPage (T21.3)', () {
    testWidgets('启用 itemExtent：ListView 固定行高 + 按需构建 + RepaintBoundary',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HighPerformanceListPage(itemCount: 1000),
        ),
      );
      await tester.pump();

      // ListView 设置了固定 itemExtent（核心优化）
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.itemExtent, 72);

      // builder 按需构建：1000 项不会全部在树里
      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(find.text('列表项 #0'), findsOneWidget);
      expect(find.text('列表项 #999'), findsNothing);
    });

    testWidgets('滚动后渲染后续项', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HighPerformanceListPage(itemCount: 1000),
        ),
      );
      await tester.pump();

      await tester.fling(find.byType(ListView), const Offset(0, -3000), 1000);
      await tester.pumpAndSettle();

      // 顶部项已被回收，后续项进入视口
      expect(find.text('列表项 #0'), findsNothing);
    });

    testWidgets('useItemExtent=false 时回退到不定高（itemExtent 为 null）',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HighPerformanceListPage(itemCount: 50, useItemExtent: false),
        ),
      );
      await tester.pump();

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.itemExtent, isNull);
    });
  });
}
