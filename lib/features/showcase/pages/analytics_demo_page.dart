import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';
import 'package:flutter_claude_app_v2/core/analytics/analytics_event.dart';
import 'package:flutter_claude_app_v2/core/analytics/exposure_tracker.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M27 数据埋点 demo：事件 API + 自动曝光 + 页面埋点说明（实时日志面板）。
class AnalyticsDemoPage extends StatefulWidget {
  const AnalyticsDemoPage({super.key});

  @override
  State<AnalyticsDemoPage> createState() => _AnalyticsDemoPageState();
}

class _AnalyticsDemoPageState extends State<AnalyticsDemoPage> {
  final ValueNotifier<List<String>> _log = ValueNotifier<List<String>>(
    const <String>[],
  );
  late final _DemoAnalytics _analytics = _DemoAnalytics(_log);

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      moduleId: 'M27',
      title: '数据埋点',
      children: <Widget>[
        DemoSection(
          title: '实时埋点日志',
          description: '下方操作触发的埋点会即时显示（演示用本地记录实现）。',
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _log,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return const DemoResultRow('日志', '（暂无）');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final line in items)
                    Text(line, style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            },
          ),
        ),
        DemoSection(
          title: '事件埋点 API（T27.4）',
          description: 'AnalyticsEvent 结构化事件 + track 扩展；参数自动去 null。',
          child: Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: <Widget>[
              FilledButton(
                onPressed: () =>
                    _analytics.track(AnalyticsEvent.tap('buy_button')),
                child: const Text('track tap'),
              ),
              FilledButton.tonal(
                onPressed: () => _analytics.logEvent(
                  'add_to_cart',
                  params: const {'id': 'sku_1', 'qty': 2, 'note': null},
                ),
                child: const Text('logEvent'),
              ),
              OutlinedButton(
                onPressed: () => _analytics.setUserId('u_1001'),
                child: const Text('setUserId'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '自动曝光埋点（T27.3）',
          description: '横向滚动，卡片进入视口（≥60%）自动上报一次 element_exposure。',
          child: SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (var i = 0; i < 8; i++)
                  ExposureTracker(
                    exposureName: 'card_$i',
                    analytics: _analytics,
                    threshold: 0.6,
                    child: Card(
                      child: SizedBox(
                        width: 120,
                        child: Center(child: Text('卡片 #$i')),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const DemoSection(
          title: '自动页面埋点（T27.2）',
          description: 'AnalyticsRouteObserver 已挂到 go_router，页面进入/返回自动上报 '
              'screen_view（见 AppLogger 日志）。本机日志面板不含页面事件，因其走全局 '
              'Analytics。',
          child: DemoResultRow('集成', 'createAppRouter(extraObservers: [...])'),
        ),
      ],
    );
  }
}

/// 演示用本地记录实现，把埋点写进 [log] 供 UI 显示。
class _DemoAnalytics implements Analytics {
  _DemoAnalytics(this.log);

  final ValueNotifier<List<String>> log;

  void _add(String line) {
    log.value = <String>[line, ...log.value].take(8).toList();
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    _add('event: $name ${params ?? ''}');
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, Object?>? params,
  }) async {
    _add('screen: $screenName');
  }

  @override
  Future<void> setUserId(String? id) async => _add('userId: $id');

  @override
  Future<void> setUserProperty(String name, Object? value) async =>
      _add('prop: $name=$value');
}
