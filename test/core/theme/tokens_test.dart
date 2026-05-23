import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/elevation_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpacingTokens', () {
    test('阶梯单调递增', () {
      final scale = <double>[
        SpacingTokens.xs,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.xl,
        SpacingTokens.xxl,
        SpacingTokens.xxxl,
      ];
      for (var i = 1; i < scale.length; i++) {
        expect(scale[i], greaterThan(scale[i - 1]));
      }
    });

    test('基准 4dp', () {
      expect(SpacingTokens.xs, 4);
      expect(SpacingTokens.md, 16);
    });
  });

  group('TypographyTokens', () {
    test('字号阶梯：display > headline > title > body > label', () {
      expect(TypographyTokens.displayLarge,
          greaterThan(TypographyTokens.headlineLarge));
      expect(TypographyTokens.headlineLarge,
          greaterThan(TypographyTokens.titleLarge));
      expect(TypographyTokens.bodyLarge,
          greaterThan(TypographyTokens.bodySmall));
    });
  });

  group('RadiusTokens', () {
    test('BorderRadius 快捷方式与数值一致', () {
      expect(RadiusTokens.allMd.topLeft.x, RadiusTokens.md);
      expect(RadiusTokens.pill.topLeft.x, RadiusTokens.full);
    });
  });

  group('ElevationTokens.shadow', () {
    test('elevation 0 → 无阴影', () {
      expect(ElevationTokens.shadow(0), isEmpty);
    });

    test('elevation > 0 → 一条阴影，blur 随 elevation 增大', () {
      final s1 = ElevationTokens.shadow(ElevationTokens.level1);
      final s3 = ElevationTokens.shadow(ElevationTokens.level3);
      expect(s1.single.blurRadius, lessThan(s3.single.blurRadius));
    });
  });

  group('MotionTokens', () {
    test('时长阶梯单调递增', () {
      expect(MotionTokens.fast, lessThan(MotionTokens.normal));
      expect(MotionTokens.normal, lessThan(MotionTokens.slow));
      expect(MotionTokens.slow, lessThan(MotionTokens.slowest));
    });

    test('曲线常量可用', () {
      expect(MotionTokens.standard, isA<Curve>());
      expect(MotionTokens.emphasizedDecelerate, isA<Curve>());
    });
  });
}
