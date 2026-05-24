import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/native/native_platform_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativePlatformView.isSupportedOn (T26.4)', () {
    test('Android / iOS 支持，其它平台不支持', () {
      expect(NativePlatformView.isSupportedOn(TargetPlatform.android), isTrue);
      expect(NativePlatformView.isSupportedOn(TargetPlatform.iOS), isTrue);
      expect(NativePlatformView.isSupportedOn(TargetPlatform.linux), isFalse);
      expect(NativePlatformView.isSupportedOn(TargetPlatform.macOS), isFalse);
      expect(NativePlatformView.isSupportedOn(TargetPlatform.windows), isFalse);
    });
  });

  group('NativePlatformView 渲染 (T26.4)', () {
    testWidgets('不支持平台 → 显示自定义 fallback', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await tester.pumpWidget(
        const MaterialApp(
          home: NativePlatformView(
            viewType: 'demo_view',
            fallback: Text('自定义占位'),
          ),
        ),
      );
      expect(find.text('自定义占位'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('不支持平台 + 无 fallback → 默认占位文案', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await tester.pumpWidget(
        const MaterialApp(
          home: NativePlatformView(viewType: 'demo_view'),
        ),
      );
      expect(find.text('当前平台不支持嵌入原生视图'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
