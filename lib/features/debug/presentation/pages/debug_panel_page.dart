import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/core/debug/cache_cleaner.dart';
import 'package:flutter_claude_app_v2/core/debug/debug_log_store.dart';
import 'package:flutter_claude_app_v2/core/debug/debug_overrides.dart';
import 'package:flutter_claude_app_v2/core/debug/device_info_service.dart';
import 'package:flutter_claude_app_v2/core/debug/network_inspector.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// Debug 面板（M29）：设备 / 环境 / 日志 / 网络 / 缓存 五个 Tab。
///
/// 仅应在 dev/staging 通过 DebugEntry 进入（见 `core/debug/debug_entry.dart`）。
class DebugPanelPage extends StatefulWidget {
  const DebugPanelPage({super.key});

  @override
  State<DebugPanelPage> createState() => _DebugPanelPageState();
}

class _DebugPanelPageState extends State<DebugPanelPage> {
  final DeviceInfoService _device = getIt<DeviceInfoService>();
  final DebugOverrides _overrides = getIt<DebugOverrides>();
  final DebugLogStore _logs = getIt<DebugLogStore>();
  final NetworkInspector _network = getIt<NetworkInspector>();
  final CacheCleaner _cache = getIt<CacheCleaner>();

  final TextEditingController _baseUrlCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  DebugLogLevel _minLevel = DebugLogLevel.trace;

  @override
  void initState() {
    super.initState();
    _baseUrlCtrl.text = _overrides.baseUrlOverride ?? '';
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug 面板'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: '设备'),
              Tab(text: '环境'),
              Tab(text: '日志'),
              Tab(text: '网络'),
              Tab(text: '缓存'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _deviceTab(),
            _envTab(),
            _logsTab(),
            _networkTab(),
            _cacheTab(),
          ],
        ),
      ),
    );
  }

  // ── 设备（T29.6）──
  Widget _deviceTab() {
    final info = _device.snapshot();
    return ListView(
      children: <Widget>[
        for (final entry in info.entries)
          ListTile(
            dense: true,
            title: Text(entry.key),
            subtitle: Text(entry.value),
          ),
      ],
    );
  }

  // ── 环境切换（T29.2）──
  Widget _envTab() {
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: <Widget>[
        Text('当前 BaseUrl 覆盖：${_overrides.baseUrlOverride ?? '（无）'}'),
        const SizedBox(height: SpacingTokens.sm),
        TextField(
          controller: _baseUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'BaseUrl 覆盖',
            hintText: 'https://staging-api.example.com',
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: SpacingTokens.sm,
          children: <Widget>[
            FilledButton(
              onPressed: () async {
                await _overrides.setBaseUrl(_baseUrlCtrl.text.trim());
                if (mounted) setState(() {});
              },
              child: const Text('设置'),
            ),
            OutlinedButton(
              onPressed: () async {
                await _overrides.clearBaseUrl();
                _baseUrlCtrl.clear();
                if (mounted) setState(() {});
              },
              child: const Text('清除'),
            ),
          ],
        ),
      ],
    );
  }

  // ── 日志查看器（T29.3）──
  Widget _logsTab() {
    final filtered = _logs.filter(minLevel: _minLevel, query: _searchCtrl.text);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: '搜索日志',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              DropdownButton<DebugLogLevel>(
                value: _minLevel,
                onChanged: (v) => setState(() => _minLevel = v ?? _minLevel),
                items: <DropdownMenuItem<DebugLogLevel>>[
                  for (final l in DebugLogLevel.values)
                    DropdownMenuItem<DebugLogLevel>(
                      value: l,
                      child: Text(l.name),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('暂无日志'))
              : ListView.builder(
                  itemExtent: 56,
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    return ListTile(
                      dense: true,
                      leading: Text(r.level.name.toUpperCase()),
                      title: Text(r.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                ),
        ),
        OverflowBar(
          children: <Widget>[
            TextButton(
              onPressed: () => setState(_logs.clear),
              child: const Text('清空'),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _logs.exportAsText()));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('日志已复制到剪贴板')),
                  );
                }
              },
              child: const Text('导出'),
            ),
          ],
        ),
      ],
    );
  }

  // ── 网络面板（T29.4）──
  Widget _networkTab() {
    final records = _network.records;
    return Column(
      children: <Widget>[
        Expanded(
          child: records.isEmpty
              ? const Center(child: Text('暂无请求'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, i) {
                    final r = records[i];
                    return ListTile(
                      dense: true,
                      leading: Text('${r.statusCode ?? '-'}'),
                      title: Text(
                        '${r.method} ${r.url}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${r.durationMs ?? '-'}ms${r.error == null ? '' : ' · ${r.error}'}',
                      ),
                      textColor: r.isError
                          ? Theme.of(context).colorScheme.error
                          : null,
                    );
                  },
                ),
        ),
        OverflowBar(
          children: <Widget>[
            TextButton(
              onPressed: () => setState(_network.clear),
              child: const Text('清空'),
            ),
          ],
        ),
      ],
    );
  }

  // ── 缓存清理（T29.5）──
  Widget _cacheTab() {
    Future<void> run(String label, Future<void> Function() action) async {
      final messenger = ScaffoldMessenger.of(context);
      await action();
      messenger.showSnackBar(SnackBar(content: Text('$label 已清理')));
    }

    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: <Widget>[
        FilledButton.tonal(
          onPressed: () => run('键值存储', _cache.clearKeyValue),
          child: const Text('清理键值存储'),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton.tonal(
          onPressed: () => run('安全存储', _cache.clearSecure),
          child: const Text('清理安全存储'),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton.tonal(
          onPressed: () => run('图片缓存', () async => _cache.clearImageCache()),
          child: const Text('清理图片缓存'),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton(
          onPressed: () => run('全部缓存', _cache.clearAll),
          child: const Text('一键清理全部'),
        ),
      ],
    );
  }
}
