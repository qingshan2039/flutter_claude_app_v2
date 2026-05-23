import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/responsive/font_scaling.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FontScaling.clamp', () {
    test('超过上限被钳制到 max', () {
      final scaler = FontScaling.clamp(const TextScaler.linear(2));
      expect(scaler.scale(10), 14.0); // 2.0 → 钳到 1.4
    });

    test('低于下限被钳制到 min', () {
      final scaler = FontScaling.clamp(const TextScaler.linear(0.5));
      expect(scaler.scale(10), 8.0); // 0.5 → 钳到 0.8
    });

    test('区间内不变', () {
      final scaler =
          FontScaling.clamp(const TextScaler.linear(1.1));
      expect(scaler.scale(10), closeTo(11.0, 0.001));
    });

    test('默认上下限 [0.8, 1.4]', () {
      expect(FontScaling.minScale, 0.8);
      expect(FontScaling.maxScale, 1.4);
    });
  });

  group('ClampedTextScaling widget', () {
    testWidgets('把超大 textScaler 钳制后下传', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 3.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      late TextScaler captured;
      await tester.pumpWidget(
        MaterialApp(
          home: ClampedTextScaling(
            child: Builder(
              builder: (context) {
                captured = MediaQuery.textScalerOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // 3.0 应被钳制到 1.4
      expect(captured.scale(10), 14.0);
    });
  });
}
