import 'dart:convert';

import 'package:flutter_claude_app_v2/core/privacy/data_export.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProfileSource implements DataExportSource {
  @override
  String get section => 'profile';
  @override
  Future<Map<String, dynamic>> collect() async => <String, dynamic>{
    'name': 'Neo',
    'email': 'neo@example.com',
  };
}

class _SettingsSource implements DataExportSource {
  @override
  String get section => 'settings';
  @override
  Future<Map<String, dynamic>> collect() async => <String, dynamic>{
    'locale': 'zh',
    'darkMode': true,
  };
}

void main() {
  group('DataExportService (T24.4)', () {
    test('buildExport 聚合各来源 + 导出时间', () async {
      final service = DataExportService()
        ..register(_ProfileSource())
        ..register(_SettingsSource());

      final export = await service.buildExport();
      expect(export['exportedAt'], isA<String>());
      final sections = export['sections']! as Map<String, dynamic>;
      expect(sections.keys, <String>['profile', 'settings']);
      expect((sections['profile']! as Map)['name'], 'Neo');
      expect((sections['settings']! as Map)['darkMode'], true);
    });

    test('exportAsJson 产出合法 JSON', () async {
      final service = DataExportService()..register(_ProfileSource());
      final jsonStr = await service.exportAsJson();

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['sections'], isA<Map<String, dynamic>>());
      expect(
        ((decoded['sections']! as Map)['profile']! as Map)['email'],
        'neo@example.com',
      );
    });

    test('无来源 → sections 为空', () async {
      final export = await DataExportService().buildExport();
      expect((export['sections']! as Map).isEmpty, isTrue);
    });
  });
}
