import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/utils/bottom_sheet_utils.dart';
import 'package:flutter_claude_app_v2/shared/utils/overlay_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// 把 OverlayService 的全局 Key 挂到 MaterialApp（模拟 app.dart 的接线）。
Widget _host(OverlayService o) => MaterialApp(
  scaffoldMessengerKey: o.scaffoldMessengerKey,
  navigatorKey: o.navigatorKey,
  home: const Scaffold(body: SizedBox.expand()),
);

void main() {
  group('OverlayService Toast (T14.5)', () {
    testWidgets('showSuccess 弹出 SnackBar + 文案', (tester) async {
      final overlay = OverlayService();
      await tester.pumpWidget(_host(overlay));

      overlay.showSuccess('保存成功');
      await tester.pump(); // 开始入场
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('保存成功'), findsOneWidget);
    });

    testWidgets('hideToast 关闭当前 Toast', (tester) async {
      final overlay = OverlayService();
      await tester.pumpWidget(_host(overlay));

      overlay.showError('错误');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('错误'), findsOneWidget);

      overlay.hideToast();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('错误'), findsNothing);
    });
  });

  group('OverlayService Dialog (T14.5)', () {
    testWidgets('showConfirm 确认 → true', (tester) async {
      final overlay = OverlayService();
      await tester.pumpWidget(_host(overlay));

      final future = overlay.showConfirm(
        title: '删除？',
        message: '不可撤销',
        confirmLabel: '删除',
        destructive: true,
      );
      await tester.pumpAndSettle();

      expect(find.text('删除？'), findsOneWidget);
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
    });

    testWidgets('showConfirm 取消 → false', (tester) async {
      final overlay = OverlayService();
      await tester.pumpWidget(_host(overlay));

      final future = overlay.showConfirm(title: 'T');
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });

    testWidgets('showAppDialog 返回所点按钮的 value', (tester) async {
      final overlay = OverlayService();
      await tester.pumpWidget(_host(overlay));

      final future = overlay.showAppDialog<String>(
        title: '选择',
        actions: const <AppDialogAction<String>>[
          AppDialogAction<String>(label: 'A', value: 'a'),
          AppDialogAction<String>(label: 'B', value: 'b', isDefault: true),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(await future, 'b');
    });
  });

  group('BottomSheet (T14.6)', () {
    testWidgets('showAppBottomSheet 显示内容', (tester) async {
      final overlay = OverlayService();
      await tester.pumpWidget(_host(overlay));

      unawaited(
        overlay.showAppBottomSheet<void>(
          builder: (_) => const Text('底部内容'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('底部内容'), findsOneWidget);
    });
  });
}
