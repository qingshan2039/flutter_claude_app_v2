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

    testWidgets('cacheWidth/Height → 按 DPR 换算成 memCacheWidth/Height (T21.4)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(
            'https://example.com/a.png',
            width: 100,
            height: 100,
            cacheWidth: 100,
            cacheHeight: 80,
          ),
        ),
      );
      await tester.pump();

      final dpr = tester.view.devicePixelRatio;
      final cni = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cni.memCacheWidth, (100 * dpr).round());
      expect(cni.memCacheHeight, (80 * dpr).round());
    });

    testWidgets('thumbnail 构造 → 限制内存解码 + 限制磁盘缓存尺寸 (T21.4)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppImage.thumbnail('https://example.com/a.png', size: 96),
        ),
      );
      await tester.pump();

      final dpr = tester.view.devicePixelRatio;
      final cni = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      // 内存解码尺寸按 DPR 换算
      expect(cni.memCacheWidth, (96 * dpr).round());
      // 磁盘缓存原图尺寸 = 2×size（原始像素，不乘 DPR）
      expect(cni.maxWidthDiskCache, 192);
      expect(cni.maxHeightDiskCache, 192);
      // allSm 圆角 → 套 ClipRRect
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('默认构造不设 cache → memCacheWidth 为 null (按原图解码)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppImage('https://example.com/a.png')),
      );
      await tester.pump();

      final cni = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cni.memCacheWidth, isNull);
      expect(cni.memCacheHeight, isNull);
    });

    testWidgets('semanticLabel → 包裹 Semantics(image, label) (T22.1)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(
            'https://example.com/a.png',
            width: 50,
            height: 50,
            semanticLabel: '产品封面',
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(AppImage)),
        matchesSemantics(label: '产品封面', isImage: true),
      );
    });

    testWidgets('不提供 semanticLabel → 不额外加图片语义', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppImage('https://example.com/a.png')),
      );
      await tester.pump();
      // 没有带 label 的 image 语义节点
      expect(find.bySemanticsLabel('产品封面'), findsNothing);
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
