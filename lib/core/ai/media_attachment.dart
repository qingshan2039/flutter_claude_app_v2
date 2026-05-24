import 'package:flutter/foundation.dart';

/// 多模态附件类型（T32.3）。
enum MediaType { image, audio }

/// 多模态附件（T32.3）：随 LLM 请求上传的图片/音频等。
@immutable
class MediaAttachment {
  const MediaAttachment({
    required this.name,
    required this.type,
    required this.sizeBytes,
    this.path,
  });

  final String name;
  final MediaType type;
  final int sizeBytes;

  /// 本地路径（选取后；可空）。
  final String? path;

  /// 人类可读大小。
  String get readableSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
