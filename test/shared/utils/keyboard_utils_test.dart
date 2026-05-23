import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/utils/keyboard_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DismissKeyboardOnTap (T14.7)', () {
    testWidgets('点空白处收起键盘（焦点移除）', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissKeyboardOnTap(
              child: Column(
                children: <Widget>[
                  TextField(focusNode: node),
                  const SizedBox(height: 300, width: double.infinity),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(node.hasFocus, isTrue);

      // 点输入框下方的空白区域。
      await tester.tapAt(const Offset(200, 200));
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });
  });

  group('KeyboardUtils (T14.7)', () {
    testWidgets('inset / isOpen 读取键盘高度', (tester) async {
      late double inset;
      late bool open;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              viewInsets: EdgeInsets.only(bottom: 300),
            ),
            child: Builder(
              builder: (context) {
                inset = KeyboardUtils.inset(context);
                open = KeyboardUtils.isOpen(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(inset, 300);
      expect(open, isTrue);
    });

    testWidgets('KeyboardSpacer 高度 = 键盘高度 + extra', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 100)),
            // Align 给松约束，让 SizedBox 取自身高度（否则 home 紧约束会撑满）。
            child: Align(
              alignment: Alignment.topLeft,
              child: KeyboardSpacer(extra: 8),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(KeyboardSpacer));
      expect(size.height, 108);
    });
  });
}
