import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/features/detail/domain/entities/article_detail.dart';
import 'package:flutter_claude_app_v2/features/detail/domain/repositories/detail_repository.dart';
import 'package:injectable/injectable.dart';

/// 占位实现（T19.3）：模拟 350ms 网络。id 为 'error' 时抛异常以演示错误态。
@LazySingleton(as: DetailRepository)
class DetailRepositoryImpl implements DetailRepository {
  const DetailRepositoryImpl();

  @override
  Future<ArticleDetail> fetchDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (id == 'error') {
      throw const NetworkException(message: '加载详情失败（演示）');
    }
    return ArticleDetail(
      id: id,
      title: '文章 #$id 详情',
      author: 'Demo Author',
      body: '这是文章 #$id 的正文内容。\n\n'
          '本页演示：路由参数传递（id=$id）、异步数据加载、AsyncValue 三态'
          '（loading / data / error）。把 id 改成 "error" 可看错误态与重试。\n\n'
          '${'示例段落。' * 20}',
    );
  }
}
