import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/ai/attachment_picker.dart';
import 'package:flutter_claude_app_v2/core/ai/llm_client.dart';
import 'package:flutter_claude_app_v2/core/ai/media_attachment.dart';
import 'package:flutter_claude_app_v2/core/ai/media_picker.dart';
import 'package:flutter_claude_app_v2/core/ai/streaming_text_view.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M32 AI 能力集成预留 demo：LLM 抽象层 + 流式响应 + 多模态附件 + AI 辅助开发配置。
class AiDemoPage extends StatefulWidget {
  const AiDemoPage({super.key});

  @override
  State<AiDemoPage> createState() => _AiDemoPageState();
}

class _AiDemoPageState extends State<AiDemoPage> {
  final LlmClient _client = getIt<LlmClient>();
  final TextEditingController _inputCtrl =
      TextEditingController(text: '用一句话介绍 Flutter');
  Stream<String>? _responseStream;
  int _attachmentCount = 0;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final request = LlmRequest(
      model: 'demo-model',
      messages: <LlmMessage>[LlmMessage.user(text)],
    );
    // stream() 产出 LlmChunk；StreamingTextView 接收增量 String，故映射出 delta。
    setState(() {
      _responseStream = _client.stream(request).map((c) => c.delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DemoScaffold(
      moduleId: 'M32',
      title: 'AI 能力集成预留',
      children: <Widget>[
        DemoSection(
          title: '流式对话（T32.1 / T32.2）',
          description: 'LlmClient 统一接口（桩实现本地模拟，不联网/免 Key）。'
              'stream() 逐 token 返回，StreamingTextView 累积显示并带光标，'
              '结束自动去光标。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '输入你的问题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send),
                label: const Text('发送（流式）'),
              ),
              const SizedBox(height: SpacingTokens.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SpacingTokens.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _responseStream == null
                    ? Text(
                        '点击「发送（流式）」查看逐字回复…',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : StreamingTextView(
                        stream: _responseStream!,
                        style: theme.textTheme.bodyMedium,
                      ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '多模态附件（T32.3）',
          description: 'MediaPicker 选取图片/音频，AttachmentPicker 以 chip 展示并可'
              '移除。（showcase 用演示选取器返回合成附件；生产接 image_picker / '
              'file_picker。）',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AttachmentPicker(
                picker: const _DemoMediaPicker(),
                onChanged: (list) =>
                    setState(() => _attachmentCount = list.length),
              ),
              const SizedBox(height: SpacingTokens.sm),
              DemoResultRow('已选附件数', '$_attachmentCount'),
            ],
          ),
        ),
        const DemoSection(
          title: 'AI 辅助开发配置（T32.4）',
          description: '已交付以下文件，统一各 AI 编码助手对本项目的认知'
              '（架构分层、命名、DI、测试与提交约定），新成员/AI 即开即用。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('Cursor', '.cursorrules'),
              DemoResultRow('Claude', 'CLAUDE.md'),
              DemoResultRow('Copilot', '.github/copilot-instructions.md'),
              DemoResultRow('指南', 'docs/ai/AI_ASSISTED_DEV.md'),
            ],
          ),
        ),
      ],
    );
  }
}

/// showcase 演示用选取器：返回合成附件，便于直观看到 chip 效果（不依赖真实插件）。
///
/// 生产环境由 DI 绑定的真实 [MediaPicker]（image_picker / file_picker）替代。
class _DemoMediaPicker implements MediaPicker {
  const _DemoMediaPicker();

  @override
  Future<MediaAttachment?> pickImage() async => const MediaAttachment(
        name: 'demo_image.jpg',
        type: MediaType.image,
        sizeBytes: 2048,
      );

  @override
  Future<MediaAttachment?> pickAudio() async => const MediaAttachment(
        name: 'demo_clip.mp3',
        type: MediaType.audio,
        sizeBytes: 4096,
      );
}
