import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/ai/attachment_picker.dart';
import 'package:flutter_claude_app_v2/core/ai/media_attachment.dart';
import 'package:flutter_claude_app_v2/core/ai/media_picker.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePicker implements MediaPicker {
  _FakePicker({this.image});
  final MediaAttachment? image;
  @override
  Future<MediaAttachment?> pickImage() async => image;
  @override
  Future<MediaAttachment?> pickAudio() async => null;
}

void main() {
  group('MediaAttachment (T32.3)', () {
    test('readableSize 格式化', () {
      expect(
        const MediaAttachment(name: 'a', type: MediaType.image, sizeBytes: 500)
            .readableSize,
        '500 B',
      );
      expect(
        const MediaAttachment(name: 'a', type: MediaType.image, sizeBytes: 2048)
            .readableSize,
        '2.0 KB',
      );
    });
  });

  group('AttachmentPicker (T32.3)', () {
    testWidgets('选取图片 → 出现 chip + onChanged 回调', (tester) async {
      List<MediaAttachment>? changed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttachmentPicker(
              picker: _FakePicker(
                image: const MediaAttachment(
                  name: 'photo.jpg',
                  type: MediaType.image,
                  sizeBytes: 2048,
                ),
              ),
              onChanged: (list) => changed = list,
            ),
          ),
        ),
      );

      await tester.tap(find.text('添加图片'));
      await tester.pumpAndSettle();

      expect(find.textContaining('photo.jpg'), findsOneWidget);
      expect(changed, hasLength(1));
    });

    testWidgets('删除 chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttachmentPicker(
              picker: _FakePicker(),
              initial: const <MediaAttachment>[
                MediaAttachment(
                  name: 'clip.mp3',
                  type: MediaType.audio,
                  sizeBytes: 4096,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('clip.mp3'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.cancel)); // Chip 默认删除图标
      await tester.pumpAndSettle();
      expect(find.textContaining('clip.mp3'), findsNothing);
    });

    testWidgets('取消选取（返回 null）→ 无 chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AttachmentPicker(picker: _FakePicker())),
        ),
      );
      await tester.tap(find.text('添加图片'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNothing);
    });
  });
}
