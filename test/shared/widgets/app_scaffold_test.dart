import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppScaffold (T14.8)', () {
    testWidgets('title → 默认 AppBar；body 渲染', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(title: '页面标题', body: Text('正文')),
        ),
      );

      expect(find.widgetWithText(AppBar, '页面标题'), findsOneWidget);
      expect(find.text('正文'), findsOneWidget);
    });

    testWidgets('showAppBar:false → 无 AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(showAppBar: false, body: Text('正文')),
        ),
      );
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('isLoading → 遮罩 + spinner + 文案 + 拦截点击', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            title: 'P',
            isLoading: true,
            loadingMessage: '提交中',
            body: Text('正文'),
          ),
        ),
      );
      await tester.pump(); // 不 settle：spinner 动画

      expect(find.text('提交中'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ModalBarrier), findsWidgets);
    });

    testWidgets('非 loading → 无遮罩', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(title: 'P', body: Text('正文')),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
