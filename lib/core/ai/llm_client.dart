import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// 对话角色。
enum LlmRole { system, user, assistant }

/// 一条对话消息。
@immutable
class LlmMessage {
  const LlmMessage(this.role, this.content);
  const LlmMessage.system(this.content) : role = LlmRole.system;
  const LlmMessage.user(this.content) : role = LlmRole.user;
  const LlmMessage.assistant(this.content) : role = LlmRole.assistant;

  final LlmRole role;
  final String content;
}

/// LLM 请求。
@immutable
class LlmRequest {
  const LlmRequest({
    required this.messages,
    this.model = 'default',
    this.temperature = 0.7,
    this.maxTokens = 1024,
  });

  final List<LlmMessage> messages;
  final String model;
  final double temperature;
  final int maxTokens;
}

/// 非流式完整响应。
@immutable
class LlmResponse {
  const LlmResponse({required this.text, this.model = 'default', this.tokens});
  final String text;
  final String model;
  final int? tokens;
}

/// 流式响应分片。
@immutable
class LlmChunk {
  const LlmChunk(this.delta, {this.done = false});
  final String delta;
  final bool done;
}

/// 统一 LLM 接口（T32.1）。
///
/// 业务只依赖本接口；具体厂商（Anthropic / OpenAI / 通义千问/文心/讯飞 等国内大
/// 模型）由各自适配实现并经 DI 绑定。请求/响应模型与厂商无关。
abstract class LlmClient {
  /// 一次性返回完整结果。
  Future<LlmResponse> complete(LlmRequest request);

  /// 流式返回（逐 token/分片）。
  Stream<LlmChunk> stream(LlmRequest request);
}

/// 桩实现（T32.1）：本地模拟回复，不联网、不需 API Key，便于跑通 UI 与测试。
///
/// 生产替换为真实适配（用 M04 的 Dio 调各厂商 API），DI 改绑 `LlmClient` 即可：
/// - Anthropic：`POST https://api.anthropic.com/v1/messages`（SSE 流）
/// - OpenAI：`POST https://api.openai.com/v1/chat/completions`（`stream: true`）
/// - 国内：通义/文心/讯飞等兼容 OpenAI 或各自协议。
@LazySingleton(as: LlmClient)
class StubLlmClient implements LlmClient {
  const StubLlmClient();

  String _reply(LlmRequest request) {
    final lastUser = request.messages.lastWhere(
      (m) => m.role == LlmRole.user,
      orElse: () => const LlmMessage.user(''),
    );
    return '（模拟回复）已收到：「${lastUser.content}」。这是占位响应，'
        '接入真实 LLM 后将返回模型结果。';
  }

  @override
  Future<LlmResponse> complete(LlmRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final text = _reply(request);
    return LlmResponse(text: text, model: request.model, tokens: text.length);
  }

  @override
  Stream<LlmChunk> stream(LlmRequest request) async* {
    final words = _reply(request).split('');
    for (final w in words) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      yield LlmChunk(w);
    }
    yield const LlmChunk('', done: true);
  }
}
