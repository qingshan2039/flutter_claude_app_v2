import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M05 本地存储 — 可视化演示（KeyValue / Secure）。
class StorageDemoPage extends StatefulWidget {
  const StorageDemoPage({super.key});

  @override
  State<StorageDemoPage> createState() => _StorageDemoPageState();
}

class _StorageDemoPageState extends State<StorageDemoPage> {
  final KeyValueStorage _kv = getIt<KeyValueStorage>();
  final SecureStorage _secure = getIt<SecureStorage>();

  final TextEditingController _kvCtrl = TextEditingController(text: 'hello');
  final TextEditingController _secureCtrl = TextEditingController(text: 'secret-token');

  static const _kvKey = 'showcase.kv';
  static const _secureKey = 'showcase.secure';

  String _kvRead = '(未读取)';
  String _secureRead = '(未读取)';

  @override
  void dispose() {
    _kvCtrl.dispose();
    _secureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: '本地存储',
      moduleId: 'M05',
      children: <Widget>[
        DemoSection(
          title: 'KeyValueStorage（SharedPreferences）',
          description: '写入后读取，重启 App 仍在',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _kvCtrl,
                decoration: const InputDecoration(labelText: '要保存的值'),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await _kv.setString(_kvKey, _kvCtrl.text);
                        setState(() => _kvRead = '已写入');
                      },
                      child: const Text('保存'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(
                        () => _kvRead = _kv.getString(_kvKey) ?? '(空)',
                      ),
                      child: const Text('读取'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DemoResultRow('读取结果', _kvRead),
            ],
          ),
        ),
        DemoSection(
          title: 'SecureStorage（加密）',
          description: 'iOS Keychain / Android EncryptedSharedPreferences',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _secureCtrl,
                decoration: const InputDecoration(labelText: '要加密保存的值'),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await _secure.write(_secureKey, _secureCtrl.text);
                        setState(() => _secureRead = '已加密写入');
                      },
                      child: const Text('保存'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final v = await _secure.read(_secureKey);
                        setState(() => _secureRead = v ?? '(空)');
                      },
                      child: const Text('读取'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DemoResultRow('读取结果', _secureRead),
            ],
          ),
        ),
        const DemoSection(
          title: 'Hive 数据库 + Schema 迁移',
          description: 'AppDatabase（recent_queries box）+ DatabaseMigrator 版本管理',
          child: Text('AppDatabase 已在启动时初始化（@preResolve），'
              '提供 addRecentQuery / recentQueries / clearRecentQueries；'
              'DatabaseMigrator 负责按版本号迁移 schema。'),
        ),
      ],
    );
  }
}
