import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/states.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('LoadingWidget (T14.1)', () {
    testWidgets('局部：spinner + 文案', (tester) async {
      await tester.pumpWidget(_host(const LoadingWidget(message: '加载中')));
      await tester.pump(); // 不 settle：spinner 永久动画

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('加载中'), findsOneWidget);
    });

    testWidgets('全屏：撑满父约束', (tester) async {
      await tester.pumpWidget(_host(const LoadingWidget.fullscreen()));
      await tester.pump();

      final size = tester.getSize(find.byType(CircularProgressIndicator));
      expect(size.width, greaterThan(0));
    });
  });

  group('SkeletonLoader (T14.1)', () {
    testWidgets('渲染 itemCount 行骨架块', (tester) async {
      await tester.pumpWidget(_host(const SkeletonLoader(itemCount: 3)));
      await tester.pump();

      expect(find.byType(SkeletonBox), findsWidgets);
    });
  });

  group('EmptyWidget (T14.1)', () {
    testWidgets('标题/文案可见；操作按钮触发回调', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          EmptyWidget(
            title: '空空如也',
            message: '没有内容',
            actionLabel: '去添加',
            onAction: () => tapped = true,
          ),
        ),
      );

      expect(find.text('空空如也'), findsOneWidget);
      expect(find.text('没有内容'), findsOneWidget);

      await tester.tap(find.text('去添加'));
      expect(tapped, isTrue);
    });

    testWidgets('无 onAction 时不显示按钮', (tester) async {
      await tester.pumpWidget(
        _host(const EmptyWidget(actionLabel: '不该出现')),
      );
      expect(find.text('不该出现'), findsNothing);
    });
  });

  group('AppErrorView (T14.1)', () {
    testWidgets('有 onRetry → 显示重试并回调', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _host(AppErrorView(message: '失败', onRetry: () => retried = true)),
      );

      expect(find.text('失败'), findsOneWidget);
      await tester.tap(find.text('重试'));
      expect(retried, isTrue);
    });

    testWidgets('无 onRetry → 不显示重试', (tester) async {
      await tester.pumpWidget(_host(const AppErrorView()));
      expect(find.text('重试'), findsNothing);
    });
  });

  group('FailureView (T14.1 + M03)', () {
    testWidgets('NetworkFailure → NetworkErrorWidget', (tester) async {
      await tester.pumpWidget(
        _host(const FailureView(failure: NetworkFailure())),
      );
      expect(find.byType(NetworkErrorWidget), findsOneWidget);
    });

    testWidgets('ServerFailure → 标题含状态码', (tester) async {
      await tester.pumpWidget(
        _host(
          const FailureView(
            failure: ServerFailure(message: '挂了', statusCode: 500),
          ),
        ),
      );
      expect(find.textContaining('500'), findsOneWidget);
      expect(find.text('挂了'), findsOneWidget);
    });

    testWidgets('UnauthorizedFailure → 去登录', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          FailureView(
            failure: const UnauthorizedFailure(),
            onRetry: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('去登录'));
      expect(tapped, isTrue);
    });
  });
}
