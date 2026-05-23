import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/features/detail/domain/entities/article_detail.dart';
import 'package:flutter_claude_app_v2/features/detail/domain/repositories/detail_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 桥接 DI 的 [DetailRepository]；测试可 override。
final Provider<DetailRepository> detailRepositoryProvider =
    Provider<DetailRepository>(
      (ref) => getIt<DetailRepository>(),
      name: 'detailRepositoryProvider',
    );

/// 按 id 异步加载文章详情（T19.3）。family 让每个 id 独立缓存/请求；
/// 抛异常自动进入 AsyncError，页面用 AsyncValueWidget 三态渲染。
final AutoDisposeFutureProviderFamily<ArticleDetail, String>
articleDetailProvider =
    FutureProvider.autoDispose.family<ArticleDetail, String>(
      (ref, id) => ref.watch(detailRepositoryProvider).fetchDetail(id),
      name: 'articleDetailProvider',
    );
