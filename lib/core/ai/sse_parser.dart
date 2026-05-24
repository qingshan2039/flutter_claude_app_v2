import 'package:flutter/foundation.dart';

/// 一个 SSE（Server-Sent Events）事件（T32.2）。
@immutable
class SseEvent {
  const SseEvent({required this.data, this.event});

  /// 事件类型（`event:` 字段，可空）。
  final String? event;

  /// 数据负载（`data:` 字段，多行合并）。
  final String data;

  /// LLM 流的结束哨兵（OpenAI 风格 `data: [DONE]`）。
  bool get isDone => data == '[DONE]';
}

/// SSE 解析器（T32.2）。
///
/// 把 SSE 文本块解析为 [SseEvent] 列表。事件以空行（`\n\n`）分隔，每个事件可含
/// `event:` / `data:` 字段（`data:` 多行会合并）、`:` 开头的注释行忽略。
/// 用于流式 LLM 响应（Anthropic / OpenAI 均为 SSE）。
abstract final class SseParser {
  static List<SseEvent> parse(String chunk) {
    final events = <SseEvent>[];
    for (final block in chunk.split('\n\n')) {
      if (block.trim().isEmpty) continue;
      String? event;
      final data = StringBuffer();
      for (final line in block.split('\n')) {
        if (line.startsWith(':')) continue; // 注释/心跳
        if (line.startsWith('event:')) {
          event = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          if (data.isNotEmpty) data.write('\n');
          data.write(line.substring(5).trimLeft());
        }
      }
      events.add(SseEvent(event: event, data: data.toString()));
    }
    return events;
  }
}
