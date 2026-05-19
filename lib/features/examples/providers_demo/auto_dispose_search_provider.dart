import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `autoDispose` + `family` 示例（T06.2）— 按搜索关键词加载结果，关键词改变即重算，
/// 页面销毁后自动清理。
///
/// 适合场景：
/// - 搜索页：用户切换查询词频繁，结果应跟随 dispose
/// - 列表点击进详情：详情 provider 用 family 接 ID，离开页面后自动释放
///
/// 用法：
/// ```dart
/// final asyncResults = ref.watch(autoDisposeSearchProvider('flutter'));
/// asyncResults.when(...);
/// ```
///
/// 模拟实现：对查询词返回三条加了序号的字符串。M19+ 后接入真实搜索接口。
final AutoDisposeFutureProviderFamily<List<String>, String>
autoDisposeSearchProvider =
    FutureProvider.autoDispose.family<List<String>, String>(
      (ref, query) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        if (query.isEmpty) return const <String>[];
        return <String>[
          '$query #1',
          '$query #2',
          '$query #3',
        ];
      },
      name: 'autoDisposeSearchProvider',
    );
