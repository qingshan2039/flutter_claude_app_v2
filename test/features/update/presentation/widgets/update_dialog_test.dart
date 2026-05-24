import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/update/app_version.dart';
import 'package:flutter_claude_app_v2/core/update/update_models.dart';
import 'package:flutter_claude_app_v2/features/update/presentation/widgets/update_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

UpdateDecision _decision(UpdatePolicy policy) => UpdateDecision(
  policy: policy,
  currentVersion: AppVersion.parse('1.3.0'),
  info: UpdateInfo(
    latestVersion: AppVersion.parse('1.4.0'),
    minSupportedVersion: AppVersion.parse('1.2.0'),
    releaseNotes: '• 修复问题',
  ),
);

bool _canPop(WidgetTester tester) {
  final element = find
      .descendant(
        of: find.byType(UpdateDialog),
        matching: find.byWidgetPredicate((w) => w is PopScope),
      )
      .evaluate()
      .first;
  return (element.widget as PopScope).canPop;
}

void main() {
  group('UpdateDialog (T23.2)', () {
    testWidgets('提示更新：有「稍后」+「立即更新」，可关闭', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: UpdateDialog(decision: _decision(UpdatePolicy.optional))),
      );
      expect(find.text('发现新版本'), findsOneWidget);
      expect(find.text('稍后'), findsOneWidget);
      expect(find.text('立即更新'), findsOneWidget);
      expect(_canPop(tester), isTrue);
    });

    testWidgets('强制更新：无「稍后」，不可关闭（canPop=false）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: UpdateDialog(decision: _decision(UpdatePolicy.force))),
      );
      expect(find.text('需要更新'), findsOneWidget);
      expect(find.text('稍后'), findsNothing);
      expect(find.text('立即更新'), findsOneWidget);
      expect(_canPop(tester), isFalse);
    });

    testWidgets('showUpdateDialog：点「立即更新」返回 true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showUpdateDialog(
                    context,
                    _decision(UpdatePolicy.optional),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('立即更新'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('showUpdateDialog：点「稍后」返回 false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showUpdateDialog(
                    context,
                    _decision(UpdatePolicy.optional),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('稍后'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });
}
