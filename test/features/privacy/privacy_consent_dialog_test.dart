import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/features/privacy/presentation/widgets/privacy_consent_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({
  void Function(bool)? onResult,
  VoidCallback? onViewPrivacy,
}) =>
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final agreed = await showPrivacyConsent(
                context,
                version: '1.0.0',
                onViewPrivacy: onViewPrivacy,
              );
              onResult?.call(agreed);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

void main() {
  group('PrivacyConsentDialog (T24.1)', () {
    testWidgets('首屏：显示同意/不同意 + 政策/协议入口', (tester) async {
      await tester.pumpWidget(_host());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('隐私政策与用户协议'), findsOneWidget);
      expect(find.text('同意并继续'), findsOneWidget);
      expect(find.text('不同意'), findsOneWidget);
      expect(find.text('《隐私政策》'), findsOneWidget);
    });

    testWidgets('同意 → 返回 true', (tester) async {
      bool? result;
      await tester.pumpWidget(_host(onResult: (v) => result = v));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('同意并继续'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('不同意 → 二次确认 → 仍不同意 → 返回 false', (tester) async {
      bool? result;
      await tester.pumpWidget(_host(onResult: (v) => result = v));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('不同意'));
      await tester.pumpAndSettle();
      expect(find.text('确认不同意？'), findsOneWidget);

      await tester.tap(find.text('仍不同意'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('二次确认 → 返回同意 → 回到首屏', (tester) async {
      await tester.pumpWidget(_host());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('不同意'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('返回同意'));
      await tester.pumpAndSettle();

      expect(find.text('隐私政策与用户协议'), findsOneWidget);
      expect(find.text('确认不同意？'), findsNothing);
    });

    testWidgets('点《隐私政策》触发回调', (tester) async {
      var viewed = false;
      await tester.pumpWidget(_host(onViewPrivacy: () => viewed = true));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('《隐私政策》'));
      await tester.pump();
      expect(viewed, isTrue);
    });
  });
}
