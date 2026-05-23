import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/features/home/domain/entities/feed_item.dart';
import 'package:flutter_claude_app_v2/features/home/domain/repositories/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// 桥接 DI 的 [HomeRepository]；测试可 override 为替身。
final Provider<HomeRepository> homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => getIt<HomeRepository>(),
  name: 'homeRepositoryProvider',
);

/// 首页分页状态（T19.2）。
@immutable
class HomeFeedState {
  const HomeFeedState({
    required this.items,
    required this.hasMore,
    required this.page,
  });

  final List<FeedItem> items;
  final bool hasMore;
  final int page;
}

/// 首页信息流控制器（T19.2）：初始加载 + 下拉刷新 + 上拉分页。
class HomeFeedController extends AutoDisposeAsyncNotifier<HomeFeedState> {
  static const int _pageSize = 15;

  HomeRepository get _repo => ref.read(homeRepositoryProvider);

  @override
  Future<HomeFeedState> build() => _loadPage(1);

  Future<HomeFeedState> _loadPage(int page) async {
    final items = await _repo.fetchFeed(page: page, pageSize: _pageSize);
    return HomeFeedState(
      items: items,
      hasMore: items.length == _pageSize,
      page: page,
    );
  }

  /// 下拉刷新：回到第 1 页。
  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _loadPage(1));
  }

  /// 上拉加载下一页（追加）。
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;
    final next = current.page + 1;
    final more = await _repo.fetchFeed(page: next, pageSize: _pageSize);
    state = AsyncData<HomeFeedState>(
      HomeFeedState(
        items: <FeedItem>[...current.items, ...more],
        hasMore: more.length == _pageSize,
        page: next,
      ),
    );
  }
}

final AutoDisposeAsyncNotifierProvider<HomeFeedController, HomeFeedState>
homeFeedControllerProvider =
    AutoDisposeAsyncNotifierProvider<HomeFeedController, HomeFeedState>(
      HomeFeedController.new,
      name: 'homeFeedControllerProvider',
    );
