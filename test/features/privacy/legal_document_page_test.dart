import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/privacy/legal_documents.dart';
import 'package:flutter_claude_app_v2/features/privacy/presentation/pages/legal_document_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LegalDocumentPage (T24.5)', () {
    testWidgets('渲染隐私政策：标题 + 版本/生效日期 + 各章节', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: LegalDocumentPage(document: kPrivacyPolicy)),
      );

      expect(find.widgetWithText(AppBar, '隐私政策'), findsOneWidget);
      expect(
        find.textContaining('版本 $kPrivacyPolicyVersion'),
        findsOneWidget,
      );
      // 至少首个章节标题可见
      expect(find.text(kPrivacyPolicy.sections.first.heading), findsOneWidget);
    });

    testWidgets('渲染用户协议（版本管理字段存在）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: LegalDocumentPage(document: kUserAgreement)),
      );
      expect(find.widgetWithText(AppBar, '用户协议'), findsOneWidget);
      expect(find.textContaining('生效日期'), findsOneWidget);
    });
  });
}
