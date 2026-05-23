import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppImage (T14.3)', () {
    testWidgets('用 CachedNetworkImage，并按 borderRadius 套 ClipRRect',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(
            'https://example.com/a.png',
            width: 50,
            height: 50,
            borderRadius: RadiusTokens.allMd,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('borderRadius 为 zero 时不套 ClipRRect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppImage('https://example.com/a.png')),
      );
      await tester.pump();
      expect(find.byType(ClipRRect), findsNothing);
    });

    testWidgets('circle 构造 → 圆形裁剪', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AppImage.circle('https://example.com/a.png', size: 40)),
      );
      await tester.pump();

      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, BorderRadius.circular(20));
    });
  });

  group('RoundedClipX (T14.3)', () {
    testWidgets('.rounded() 包裹为 ClipRRect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const SizedBox(width: 10, height: 10).rounded()),
      );
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
