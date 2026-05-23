import 'dart:ui'
    show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/responsive/foldable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MediaQueryData mqWith(List<DisplayFeature> features) =>
      MediaQueryData(size: const Size(1000, 800), displayFeatures: features);

  const verticalHinge = DisplayFeature(
    bounds: Rect.fromLTWH(490, 0, 20, 800), // 高 > 宽 → 垂直铰链
    type: DisplayFeatureType.hinge,
    state: DisplayFeatureState.postureFlat,
  );

  group('FoldableUtils.hinge / isFoldable', () {
    test('无 displayFeatures → null / 非折叠', () {
      final mq = mqWith(const <DisplayFeature>[]);
      expect(FoldableUtils.hinge(mq), isNull);
      expect(FoldableUtils.isFoldable(mq), isFalse);
    });

    test('有 hinge → 检测到', () {
      final mq = mqWith(<DisplayFeature>[verticalHinge]);
      expect(FoldableUtils.hinge(mq), isNotNull);
      expect(FoldableUtils.isFoldable(mq), isTrue);
    });

    test('fold 类型也算', () {
      const fold = DisplayFeature(
        bounds: Rect.fromLTWH(0, 400, 1000, 0),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      );
      expect(FoldableUtils.hinge(mqWith(<DisplayFeature>[fold])), isNotNull);
    });

    test('cutout 类型不算铰链', () {
      const cutout = DisplayFeature(
        bounds: Rect.fromLTWH(0, 0, 50, 30),
        type: DisplayFeatureType.cutout,
        state: DisplayFeatureState.unknown,
      );
      expect(FoldableUtils.hinge(mqWith(<DisplayFeature>[cutout])), isNull);
    });
  });

  group('isVerticalHinge', () {
    test('高 > 宽 → 垂直', () {
      expect(FoldableUtils.isVerticalHinge(verticalHinge), isTrue);
    });

    test('宽 > 高 → 水平', () {
      const horizontal = DisplayFeature(
        bounds: Rect.fromLTWH(0, 395, 1000, 10),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      );
      expect(FoldableUtils.isVerticalHinge(horizontal), isFalse);
    });
  });

  group('HingeAwareTwoPane widget', () {
    testWidgets('无铰链 → 普通 Row 双栏', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HingeAwareTwoPane(
              start: Text('START'),
              end: Text('END'),
            ),
          ),
        ),
      );
      expect(find.text('START'), findsOneWidget);
      expect(find.text('END'), findsOneWidget);
    });

    testWidgets('有垂直铰链 → 两栏都渲染（避让铰链）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: mqWith(<DisplayFeature>[verticalHinge]),
            child: const Scaffold(
              body: HingeAwareTwoPane(
                start: Text('START'),
                end: Text('END'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('START'), findsOneWidget);
      expect(find.text('END'), findsOneWidget);
    });
  });
}
