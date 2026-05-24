import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/ai/media_attachment.dart';
import 'package:flutter_claude_app_v2/core/ai/media_picker.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 多模态附件选择组件（T32.3）。
///
/// 「添加图片 / 添加音频」按钮调用 [MediaPicker]，已选附件以 chip 展示并可移除；
/// 变更通过 [onChanged] 回传。[picker] 为 null 时取 `getIt<MediaPicker>()`。
class AttachmentPicker extends StatefulWidget {
  const AttachmentPicker({
    super.key,
    this.picker,
    this.initial = const <MediaAttachment>[],
    this.onChanged,
  });

  final MediaPicker? picker;
  final List<MediaAttachment> initial;
  final ValueChanged<List<MediaAttachment>>? onChanged;

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  late final MediaPicker _picker = widget.picker ?? getIt<MediaPicker>();
  late final List<MediaAttachment> _items =
      List<MediaAttachment>.of(widget.initial);

  void _emit() => widget.onChanged?.call(List<MediaAttachment>.unmodifiable(_items));

  Future<void> _add(Future<MediaAttachment?> Function() pick) async {
    final attachment = await pick();
    if (attachment == null || !mounted) return;
    setState(() => _items.add(attachment));
    _emit();
  }

  void _remove(MediaAttachment a) {
    setState(() => _items.remove(a));
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: SpacingTokens.sm,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: () => _add(_picker.pickImage),
              icon: const Icon(Icons.image_outlined),
              label: const Text('添加图片'),
            ),
            OutlinedButton.icon(
              onPressed: () => _add(_picker.pickAudio),
              icon: const Icon(Icons.mic_none_outlined),
              label: const Text('添加音频'),
            ),
          ],
        ),
        if (_items.isNotEmpty) ...<Widget>[
          const SizedBox(height: SpacingTokens.sm),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.xs,
            children: <Widget>[
              for (final a in _items)
                Chip(
                  avatar: Icon(
                    a.type == MediaType.image
                        ? Icons.image
                        : Icons.audiotrack,
                    size: 18,
                  ),
                  label: Text('${a.name} · ${a.readableSize}'),
                  onDeleted: () => _remove(a),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
