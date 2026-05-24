import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/offline/cached_fetcher.dart';
import 'package:flutter_claude_app_v2/core/offline/connectivity_service.dart';
import 'package:flutter_claude_app_v2/core/offline/optimistic.dart';
import 'package:flutter_claude_app_v2/core/offline/sync_queue.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M25 离线优先 demo：网络开关 + 缓存策略 + 同步队列 + 乐观更新。
class OfflineDemoPage extends StatefulWidget {
  const OfflineDemoPage({super.key});

  @override
  State<OfflineDemoPage> createState() => _OfflineDemoPageState();
}

class _OfflineDemoPageState extends State<OfflineDemoPage> {
  final ConnectivityService _conn = getIt<ConnectivityService>();
  final CachedFetcher _fetcher = getIt<CachedFetcher>();
  final SyncQueue _queue = getIt<SyncQueue>();

  int _netCounter = 0;
  String _cacheResult = '（未取数）';

  bool _liked = false;
  int _likes = 10;
  bool _simulateFail = false;

  bool get _online => _conn.status.isOnline;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      moduleId: 'M25',
      title: '离线优先架构',
      children: <Widget>[
        DemoSection(
          title: '网络状态（T25.4）',
          description: '用开关模拟联网/断网，驱动下面的缓存与同步行为。'
              '（生产用 connectivity_plus 接入 ConnectivityService）',
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_online ? '在线' : '离线'),
            value: _online,
            onChanged: (v) {
              _conn.setStatus(
                v ? NetworkStatus.online : NetworkStatus.offline,
              );
              setState(() {});
            },
          ),
        ),
        DemoSection(
          title: '缓存策略（T25.1）',
          description: 'networkFirst/cacheFirst/cacheOnly/networkOnly；'
              '离线时按策略回退缓存。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('结果', _cacheResult),
              const SizedBox(height: SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                runSpacing: SpacingTokens.sm,
                children: <Widget>[
                  for (final policy in CachePolicy.values)
                    OutlinedButton(
                      onPressed: () => _runCache(policy),
                      child: Text(policy.name),
                    ),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: '本地变更队列（T25.2）',
          description: '离线时把写操作入队，上线后 flush 同步。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DemoResultRow('队列长度', '${_queue.length}'),
              const SizedBox(height: SpacingTokens.sm),
              Wrap(
                spacing: SpacingTokens.sm,
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: _enqueue,
                    child: const Text('添加离线操作'),
                  ),
                  FilledButton(
                    onPressed: _flush,
                    child: const Text('上线同步 (flush)'),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: '乐观更新（T25.3）',
          description: '点赞先更 UI，再发请求；失败自动回滚。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('模拟提交失败'),
                value: _simulateFail,
                onChanged: (v) => setState(() => _simulateFail = v),
              ),
              FilledButton.tonalIcon(
                onPressed: _toggleLike,
                icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
                label: Text('$_likes 赞'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _runCache(CachePolicy policy) async {
    final result = await _fetcher.fetch<String>(
      key: 'demo.cache',
      policy: policy,
      isOnline: _online,
      maxAge: const Duration(seconds: 10),
      networkFetch: () async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        _netCounter++;
        return '服务器数据 #$_netCounter';
      },
      encode: (v) => v,
      decode: (j) => j! as String,
    );
    final stale = result.isStale ? '(陈旧)' : '';
    setState(() {
      _cacheResult =
          '${result.source.name}$stale → ${result.data ?? "无数据"}';
    });
  }

  Future<void> _enqueue() async {
    await _queue.enqueue(
      PendingOperation(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'createPost',
        payload: const <String, dynamic>{'text': '离线草稿'},
        createdAt: DateTime.now(),
      ),
    );
    setState(() {});
  }

  Future<void> _flush() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_online) {
      messenger.showSnackBar(
        const SnackBar(content: Text('当前离线，请先切到在线再同步')),
      );
      return;
    }
    final report = await _queue.flush((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return true; // demo：全部同步成功
    });
    messenger.showSnackBar(
      SnackBar(content: Text('已同步 ${report.synced} 项，失败 ${report.failed} 项')),
    );
    setState(() {});
  }

  Future<void> _toggleLike() async {
    final messenger = ScaffoldMessenger.of(context);
    final wasLiked = _liked;
    final result = await runOptimistic<bool>(
      previous: wasLiked,
      optimistic: !wasLiked,
      emit: (v) => setState(() {
        _liked = v;
        _likes = 10 + (v ? 1 : 0);
      }),
      commit: () async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (_simulateFail) throw Exception('提交失败');
      },
    );
    if (!result.committed) {
      messenger.showSnackBar(
        const SnackBar(content: Text('提交失败，已回滚')),
      );
    }
  }
}
