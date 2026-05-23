import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_refresh_list.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/states.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppRefreshList (T14.4)', () {
    testWidgets('渲染数据项 + 包 EasyRefresh', (tester) async {
      await tester.pumpWidget(
        _host(
          AppRefreshList<String>(
            items: const <String>['a', 'b', 'c'],
            onRefresh: () async {},
            itemBuilder: (_, item, _) => Text(item),
          ),
        ),
      );
      await tester.pumpAndSettle(); // 排空 EasyRefresh 首帧弹道的 0 时长 Timer

      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });

    testWidgets('空列表 → EmptyWidget', (tester) async {
      await tester.pumpWidget(
        _host(
          AppRefreshList<String>(
            items: const <String>[],
            onRefresh: () async {},
            itemBuilder: (_, item, _) => Text(item),
          ),
        ),
      );
      await tester.pumpAndSettle(); // 排空 EasyRefresh 首帧弹道的 0 时长 Timer

      expect(find.byType(EmptyWidget), findsOneWidget);
    });

    testWidgets('自定义空状态生效', (tester) async {
      await tester.pumpWidget(
        _host(
          AppRefreshList<String>(
            items: const <String>[],
            onRefresh: () async {},
            empty: const Text('自定义空'),
            itemBuilder: (_, item, _) => Text(item),
          ),
        ),
      );
      await tester.pumpAndSettle(); // 排空 EasyRefresh 首帧弹道的 0 时长 Timer

      expect(find.text('自定义空'), findsOneWidget);
    });
  });
}
