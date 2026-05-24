import 'package:flutter_claude_app_v2/core/ai/llm_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LlmMessage (T32.1)', () {
    test('便捷构造设置角色', () {
      expect(const LlmMessage.system('s').role, LlmRole.system);
      expect(const LlmMessage.user('u').role, LlmRole.user);
      expect(const LlmMessage.assistant('a').role, LlmRole.assistant);
    });
  });

  group('StubLlmClient (T32.1)', () {
    const client = StubLlmClient();
    const request = LlmRequest(
      model: 'demo-model',
      messages: <LlmMessage>[
        LlmMessage.system('你是助手'),
        LlmMessage.user('你好'),
      ],
    );

    test('complete 返回完整响应（含用户输入回显）', () async {
      final r = await client.complete(request);
      expect(r.text, contains('你好'));
      expect(r.model, 'demo-model');
      expect(r.tokens, r.text.length);
    });

    test('stream 逐片返回并以 done 结束', () async {
      final chunks = await client.stream(request).toList();
      expect(chunks.last.done, isTrue);
      final text = chunks.map((c) => c.delta).join();
      expect(text, contains('你好'));
    });
  });
}
