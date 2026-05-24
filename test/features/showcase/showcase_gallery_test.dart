import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/di_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/error_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/state_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/pages/theme_demo_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/showcase_app.dart';
import 'package:flutter_claude_app_v2/features/showcase/showcase_gallery_page.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../_helpers/storage_test_setup.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await setupStorageMocks();
    await getIt.reset();
    await configureDependencies(environment: 'dev');
    // M27 demo 含 VisibilityDetector（曝光埋点）；置 0 避免遗留 500ms 定时器
    // 在 widget 树销毁后仍 pending 触发断言。
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  tearDown(() async {
    await getIt.reset();
    await tearDownStorageMocks(tempDir);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShowcaseApp()));
    await tester.pumpAndSettle();
  }

  testWidgets(
      '画廊列出全部 24 个模块（M02-M12, M14, M15, M21-M29, M31, M32）',
      (tester) async {
    await pumpApp(tester);

    expect(find.byType(ShowcaseGalleryPage), findsOneWidget);
    expect(kShowcaseEntries.length, 24);
    // 抽查若干模块标题可见（ListView 顶部）
    expect(find.textContaining('M02'), findsOneWidget);
    expect(find.textContaining('M03'), findsOneWidget);
  });

  testWidgets('进入 M02 DI demo 渲染', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.textContaining('M02'));
    await tester.pumpAndSettle();
    expect(find.byType(DiDemoPage), findsOneWidget);
    expect(find.textContaining('flutter_claude_app_v2'), findsWidgets);
  });

  testWidgets('进入 M03 错误 demo 并触发映射', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.textContaining('M03'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorDemoPage), findsOneWidget);

    await tester.tap(find.text('NetworkException'));
    await tester.pumpAndSettle();
    expect(find.textContaining('NetworkFailure'), findsWidgets);
  });

  testWidgets('进入 M06 状态 demo，计数器可增减', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.textContaining('M06'));
    await tester.pumpAndSettle();
    expect(find.byType(StateDemoPage), findsOneWidget);

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('进入 M10 主题 demo，切换到暗色', (tester) async {
    await pumpApp(tester);
    // 滚动到 M10 再点击
    await tester.scrollUntilVisible(find.textContaining('M10'), 200);
    await tester.tap(find.textContaining('M10'));
    await tester.pumpAndSettle();
    expect(find.byType(ThemeDemoPage), findsOneWidget);

    await tester.tap(find.text('暗色'));
    await tester.pumpAndSettle();
    // 切换后仍在主题页（未崩溃）
    expect(find.byType(ThemeDemoPage), findsOneWidget);
  });

  // 回归守卫：逐个进入全部 11 个模块页，确保渲染时不抛任何异常。
  //
  // 背景：主题给按钮设了 minimumSize: Size.fromHeight(48)（最小宽度无限，
  // 用于 Column 整宽按钮）。若把这类按钮放进 Row 而不加 Expanded，Row 以
  // 无界宽度测量子项会触发 “BoxConstraints forces an infinite width” 断言。
  // 该断言只在对应 section 真正布局时才出现（懒加载 ListView 离屏不布局），
  // 故必须逐页进入验证。
  for (final entry in kShowcaseEntries) {
    testWidgets('进入 ${entry.moduleId} 页渲染且不抛异常', (tester) async {
      await pumpApp(tester);

      final tile = find.text('${entry.moduleId} · ${entry.title}');
      await tester.scrollUntilVisible(tile, 120);
      // 末尾条目滚动后中心可能仍在视口外，确保完全可见再点，避免 tap 落空。
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);

      if (entry.moduleId == 'M14') {
        // M14 含异步加载（AsyncValueWidget 400ms）与网络图片（CachedNetworkImage），
        // 不能 pumpAndSettle（会等永不停止的加载/动画）。用有界 pump 完成转场即可，
        // 仍能捕获渲染期布局异常（本守卫的核心目的）。
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
      } else {
        await tester.pumpAndSettle();
      }

      // 进入了某个 demo 页（DemoScaffold），且画廊已被覆盖。
      expect(find.byType(DemoScaffold), findsOneWidget);
      expect(find.byType(ShowcaseGalleryPage), findsNothing);
      // AppBar 标题含模块号，确认进入的是目标页。
      expect(
        find.widgetWithText(AppBar, '${entry.moduleId} · ${entry.title}'),
        findsOneWidget,
      );
    });
  }
}
