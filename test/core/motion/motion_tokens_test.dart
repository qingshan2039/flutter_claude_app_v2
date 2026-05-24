import 'package:flutter/animation.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MotionTokens (T34.1)', () {
    test('staggerDelay 随下标线性递增', () {
      expect(MotionTokens.staggerDelay(0), Duration.zero);
      expect(MotionTokens.staggerDelay(2).inMilliseconds, 100);
      expect(MotionTokens.staggerDelay(3), MotionTokens.staggerStep * 3);
    });

    test('时长阶梯单调递增', () {
      expect(MotionTokens.fast < MotionTokens.normal, isTrue);
      expect(MotionTokens.normal < MotionTokens.slow, isTrue);
      expect(MotionTokens.slow < MotionTokens.slowest, isTrue);
    });

    test('emphasized 曲线已定义（Cubic）', () {
      expect(MotionTokens.emphasized, isA<Cubic>());
    });
  });
}
