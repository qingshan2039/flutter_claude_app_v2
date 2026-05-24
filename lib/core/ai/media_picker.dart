import 'package:flutter_claude_app_v2/core/ai/media_attachment.dart';
import 'package:injectable/injectable.dart';

/// 多模态选取（T32.3）。
///
/// 业务只依赖本接口；真实实现用 `image_picker`（图片/拍照）与 `file_picker` /
/// `record`（音频）。返回 null 表示用户取消。
abstract class MediaPicker {
  Future<MediaAttachment?> pickImage();
  Future<MediaAttachment?> pickAudio();
}

/// 桩实现（T32.3）：未接入选取器时返回 null（不崩溃）。
///
/// 生产替换：
/// ```dart
/// final x = await ImagePicker().pickImage(source: ImageSource.gallery);
/// return x == null ? null : MediaAttachment(name: x.name, type: MediaType.image,
///   sizeBytes: await x.length(), path: x.path);
/// ```
@LazySingleton(as: MediaPicker)
class StubMediaPicker implements MediaPicker {
  const StubMediaPicker();

  @override
  Future<MediaAttachment?> pickImage() async => null;

  @override
  Future<MediaAttachment?> pickAudio() async => null;
}
