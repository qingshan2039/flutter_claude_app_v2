import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/widgets/async_value_widget.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AsyncValueWidget (T14.2)', () {
    testWidgets('data → data builder', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncValueWidget<int>(
            value: const AsyncData<int>(42),
            data: (v) => Text('值=$v'),
          ),
        ),
      );
      expect(find.text('值=42'), findsOneWidget);
    });

    testWidgets('loading → LoadingWidget', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncValueWidget<int>(
            value: const AsyncLoading<int>(),
            data: (v) => Text('$v'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading + skeleton → SkeletonLoader', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncValueWidget<int>(
            value: const AsyncLoading<int>(),
            skeleton: true,
            data: (v) => Text('$v'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SkeletonBox), findsWidgets);
    });

    testWidgets('error → AppErrorView + 重试回调', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _host(
          AsyncValueWidget<int>(
            value: const AsyncError<int>('boom', StackTrace.empty),
            data: (v) => Text('$v'),
            onRetry: () => retried = true,
          ),
        ),
      );
      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);

      await tester.tap(find.text('重试'));
      expect(retried, isTrue);
    });
  });
}
