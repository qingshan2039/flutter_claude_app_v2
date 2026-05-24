import 'dart:convert';

import 'package:injectable/injectable.dart';

/// 数据导出来源（T24.4）：每个模块贡献自己那部分用户数据。
abstract class DataExportSource {
  /// 导出 JSON 中的分区名（如 `profile`、`settings`）。
  String get section;

  /// 收集本分区的数据（须为可 JSON 序列化的结构）。
  Future<Map<String, dynamic>> collect();
}

/// 数据导出服务（T24.4：GDPR 数据可移植权）。
///
/// 聚合各 [DataExportSource]，打包成结构化 JSON（含导出时间），供用户下载/带走。
///
/// ```dart
/// getIt<DataExportService>()
///   ..register(_ProfileSource())
///   ..register(_SettingsSource());
/// final json = await getIt<DataExportService>().exportAsJson();
/// ```
@lazySingleton
class DataExportService {
  final List<DataExportSource> _sources = <DataExportSource>[];

  List<DataExportSource> get sources =>
      List<DataExportSource>.unmodifiable(_sources);

  /// 注册一个导出来源（配合级联 `..register(...)` 使用）。
  void register(DataExportSource source) => _sources.add(source);

  /// 构建导出包：`{exportedAt, sections: {section: data}}`。
  Future<Map<String, dynamic>> buildExport() async {
    final sections = <String, dynamic>{};
    for (final source in _sources) {
      sections[source.section] = await source.collect();
    }
    return <String, dynamic>{
      'exportedAt': DateTime.now().toIso8601String(),
      'sections': sections,
    };
  }

  /// 导出为格式化 JSON 字符串。
  Future<String> exportAsJson() async {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(await buildExport());
  }

  /// 重置（主要用于测试）。
  void reset() => _sources.clear();
}
