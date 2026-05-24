import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// 下载进度回调（已接收字节 / 总字节；总字节未知时为 -1）。
typedef ApkProgressCallback = void Function(int received, int total);

/// 国内 Android 旁加载更新（T23.5）。
///
/// 国内无 Google Play，常见方案是**自行下载 APK 并触发系统安装器**。本类负责：
/// 1. [downloadApk]：流式下载，支持**断点续传**（按本地已下载字节发 `Range` 头，
///    追加写入），返回本地文件路径。
/// 2. [installApk]：通过原生接缝触发系统安装（Android 需
///    `REQUEST_INSTALL_PACKAGES` 权限 + FileProvider）。
///
/// 安装为平台能力，用 MethodChannel `flutter_claude_app/apk_installer` 接缝，
/// 未接入/非 Android/测试时优雅降级返回 false。
abstract class ApkUpdater {
  Future<String> downloadApk(String url, {ApkProgressCallback? onProgress});

  Future<bool> installApk(String filePath);
}

@LazySingleton(as: ApkUpdater)
class ApkUpdaterImpl implements ApkUpdater {
  ApkUpdaterImpl();

  // 下载用独立 Dio（不带 App 的鉴权/baseUrl 拦截器）。
  final Dio _dio = Dio();

  static const MethodChannel channel = MethodChannel(
    'flutter_claude_app/apk_installer',
  );

  /// 断点续传请求头：从 [existingBytes] 字节处继续。
  static String rangeHeaderFor(int existingBytes) => 'bytes=$existingBytes-';

  /// 从 URL 推断文件名（去 query），缺省回退 `update.apk`。
  static String fileNameFromUrl(String url) {
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    final last = segments.isNotEmpty ? segments.last : '';
    return last.isNotEmpty ? last : 'update.apk';
  }

  @override
  Future<String> downloadApk(String url, {ApkProgressCallback? onProgress}) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/${fileNameFromUrl(url)}';
    final file = File(savePath);
    final existing = file.existsSync() ? await file.length() : 0;

    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: true,
        // 已有部分文件 → 用 Range 续传；服务端需支持（206 Partial Content）。
        headers: existing > 0
            ? <String, String>{HttpHeaders.rangeHeader: rangeHeaderFor(existing)}
            : null,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final contentLength =
        int.tryParse(
          response.headers.value(Headers.contentLengthHeader) ?? '',
        ) ??
        -1;
    final total = contentLength < 0 ? -1 : existing + contentLength;

    final sink = file.openWrite(
      mode: existing > 0 ? FileMode.append : FileMode.write,
    );
    var received = existing;
    try {
      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    return savePath;
  }

  @override
  Future<bool> installApk(String filePath) async {
    try {
      final ok = await channel.invokeMethod<bool>('install', <String, String>{
        'path': filePath,
      });
      return ok ?? false;
    } on MissingPluginException {
      return false; // 非 Android / 未接入 / 测试
    } on PlatformException {
      return false;
    }
  }
}
