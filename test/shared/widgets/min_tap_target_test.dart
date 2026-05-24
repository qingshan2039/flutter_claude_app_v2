import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/widgets/min_tap_target.dart';
import 'package:flutter_test/flutter_test.dart';

/// T22.3：最小点击区域封装测试。
void main() {
  group('MinTapTarget (T22.3)', () {
    testWidgets('小 child 的命中区域被撑到至少 48×48', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MinTapTarget(
                onTap: () {},
                semanticLabel: '关闭',
                child: const Icon(Icons.close, size: 16),
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(MinTapTarget));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      // 视觉 child 仍是小图标
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('点击整个区域（含图标外的透明区）都能触发 onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MinTapTarget(
                onTap: () => taps++,
                semanticLabel: '关闭',
                child: const Icon(Icons.close, size: 16),
              ),
            ),
          ),
        ),
      );

      // 点击区域的角落（远离 16px 图标中心，但在 48×48 内）
      final topLeft = tester.getTopLeft(find.byType(MinTapTarget));
      await tester.tapAt(topLeft + const Offset(4, 4));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('提供 button 语义 + 无障碍标签', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinTapTarget(
              onTap: () {},
              semanticLabel: '收藏',
              child: const Icon(Icons.star, size: 16),
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(MinTapTarget)),
        matchesSemantics(label: '收藏', isButton: true, hasTapAction: true),
      );
    });

    testWidgets('onTap 为 null：保证尺寸但不是 button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MinTapTarget(
                semanticLabel: '装饰',
                child: Icon(Icons.circle, size: 12),
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(MinTapTarget));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
