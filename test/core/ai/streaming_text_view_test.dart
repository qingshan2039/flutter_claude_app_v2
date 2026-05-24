import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/ai/streaming_text_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreamingTextView (T32.2)', () {
    testWidgets('增量累积显示 + 光标 + 结束回调', (tester) async {
      final controller = StreamController<String>();
      var done = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingTextView(
              stream: controller.stream,
              onDone: () => done = true,
            ),
          ),
        ),
      );

      controller.add('你好');
      await tester.pumpAndSettle();
      expect(find.text('你好▌'), findsOneWidget); // 未结束显示光标

      controller.add('，世界');
      await tester.pumpAndSettle();
      expect(find.text('你好，世界▌'), findsOneWidget);

      await controller.close();
      await tester.pumpAndSettle();
      expect(find.text('你好，世界'), findsOneWidget); // 结束去光标
      expect(done, isTrue);
    });

    testWidgets('showCursor=false 不显示光标', (tester) async {
      final controller = StreamController<String>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingTextView(
              stream: controller.stream,
              showCursor: false,
            ),
          ),
        ),
      );
      controller.add('abc');
      await tester.pumpAndSettle();
      expect(find.text('abc'), findsOneWidget);
      await controller.close();
    });
  });
}
