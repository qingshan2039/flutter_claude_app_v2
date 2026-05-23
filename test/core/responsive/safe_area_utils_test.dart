import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/responsive/safe_area_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(MediaQueryData mq, Widget child) =>
      MaterialApp(home: MediaQuery(data: mq, child: child));

  group('SafeAreaUtils insets', () {
    testWidgets('topInset / bottomInset 读 viewPadding', (tester) async {
      const mq = MediaQueryData(
        size: Size(400, 800),
        viewPadding: EdgeInsets.only(top: 44, bottom: 34),
      );
      late BuildContext ctx;
      await tester.pumpWidget(
        host(mq, Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        })),
      );
      expect(SafeAreaUtils.topInset(ctx), 44);
      expect(SafeAreaUtils.bottomInset(ctx), 34);
      expect(SafeAreaUtils.hasBottomIndicator(ctx), isTrue);
    });

    testWidgets('无 Home Indicator → hasBottomIndicator false', (tester) async {
      const mq = MediaQueryData(
        size: Size(400, 800),
        viewPadding: EdgeInsets.only(top: 24),
      );
      late BuildContext ctx;
      await tester.pumpWidget(
        host(mq, Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        })),
      );
      expect(SafeAreaUtils.hasBottomIndicator(ctx), isFalse);
    });
  });

  group('AppSafeArea', () {
    testWidgets('默认上下避让，渲染 child', (tester) async {
      const mq = MediaQueryData(
        size: Size(400, 800),
        viewPadding: EdgeInsets.only(top: 50, bottom: 30),
        padding: EdgeInsets.only(top: 50, bottom: 30),
      );
      await tester.pumpWidget(
        host(mq, const AppSafeArea(child: Text('CONTENT'))),
      );
      expect(find.text('CONTENT'), findsOneWidget);

      // child 应被下移（顶部避让），其 top 坐标 >= padding.top
      final textTop = tester.getTopLeft(find.text('CONTENT')).dy;
      expect(textTop, greaterThanOrEqualTo(50));
    });

    testWidgets('top=false 时不避让顶部', (tester) async {
      const mq = MediaQueryData(
        size: Size(400, 800),
        viewPadding: EdgeInsets.only(top: 50),
        padding: EdgeInsets.only(top: 50),
      );
      await tester.pumpWidget(
        host(
          mq,
          const Align(
            alignment: Alignment.topLeft,
            child: AppSafeArea(top: false, child: Text('TOP')),
          ),
        ),
      );
      final textTop = tester.getTopLeft(find.text('TOP')).dy;
      expect(textTop, lessThan(50));
    });
  });
}
