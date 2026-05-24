import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/features/examples/a11y/focus_management_page.dart';
import 'package:flutter_test/flutter_test.dart';

/// T22.5：焦点管理示例测试。
FocusNode _focusOf(WidgetTester tester, String label) {
  final field = tester.widget<TextField>(
    find.widgetWithText(TextField, label),
  );
  return field.focusNode!;
}

void main() {
  group('FocusManagementPage (T22.5)', () {
    testWidgets('NumericFocusOrder 决定 Tab 顺序：A → B → C（非视觉顺序）',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FocusManagementPage()));
      await tester.pump();

      final a = _focusOf(tester, '字段 A（order 1）');
      final b = _focusOf(tester, '字段 B（order 2）');

      a.requestFocus();
      await tester.pump();
      expect(a.hasPrimaryFocus, isTrue);

      // 按 Tab → 应跳到 order 2（字段 B），而非视觉下一个（字段 C）
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(b.hasPrimaryFocus, isTrue);
    });

    testWidgets('手动聚焦：点「聚焦目标输入框」→ 目标获得焦点', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FocusManagementPage()));
      await tester.pump();

      final target = _focusOf(tester, '目标输入框');
      expect(target.hasFocus, isFalse);

      await tester.tap(find.text('聚焦目标输入框'));
      await tester.pump();
      expect(target.hasFocus, isTrue);
    });

    testWidgets('清除焦点：unfocus 后无主焦点输入框', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FocusManagementPage()));
      await tester.pump();

      _focusOf(tester, '目标输入框').requestFocus();
      await tester.pump();

      await tester.tap(find.text('清除焦点'));
      await tester.pump();
      expect(_focusOf(tester, '目标输入框').hasFocus, isFalse);
    });
  });
}
