import 'package:flutter_claude_app_v2/core/ai/sse_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SseParser (T32.2)', () {
    test('解析单个 data 事件', () {
      final events = SseParser.parse('data: hello\n\n');
      expect(events, hasLength(1));
      expect(events.single.data, 'hello');
      expect(events.single.isDone, isFalse);
    });

    test('解析多个事件 + event 字段', () {
      final events = SseParser.parse(
        'event: message\ndata: a\n\ndata: b\n\n',
      );
      expect(events, hasLength(2));
      expect(events[0].event, 'message');
      expect(events[0].data, 'a');
      expect(events[1].data, 'b');
    });

    test('多行 data 合并', () {
      final events = SseParser.parse('data: line1\ndata: line2\n\n');
      expect(events.single.data, 'line1\nline2');
    });

    test('注释行被忽略', () {
      final events = SseParser.parse(': heartbeat\ndata: x\n\n');
      expect(events.single.data, 'x');
    });

    test('[DONE] 哨兵', () {
      final events = SseParser.parse('data: [DONE]\n\n');
      expect(events.single.isDone, isTrue);
    });

    test('空块返回空列表', () {
      expect(SseParser.parse('\n\n'), isEmpty);
    });
  });
}
