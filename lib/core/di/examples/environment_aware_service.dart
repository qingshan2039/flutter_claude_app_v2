import 'package:injectable/injectable.dart';

/// 按环境注册不同实现的示例：抽象接口 + dev / prod 两套实现。
///
/// 启动时 `configureDependencies(environment: 'dev')` → 解析得 [MockApiClient]；
/// `configureDependencies(environment: 'prod')` → 解析得 [RealApiClient]；
/// 不传 environment → 两个实现都不会被注册（[ApiClient] 找不到）。
///
/// M15 多环境配置完成后，environment 会从 `--dart-define ENV=...` 注入。
abstract class ApiClient {
  Future<String> fetch();
  String get name;
}

/// dev 环境使用的桩实现：返回固定数据，避免本地调试受后端可用性影响。
@dev
@LazySingleton(as: ApiClient)
class MockApiClient implements ApiClient {
  @override
  String get name => 'MockApiClient';

  @override
  Future<String> fetch() async => 'mock-data';
}

/// prod 环境使用的真实实现（占位；M04 完成后会调用真实 dio）。
@prod
@LazySingleton(as: ApiClient)
class RealApiClient implements ApiClient {
  @override
  String get name => 'RealApiClient';

  @override
  Future<String> fetch() async => 'real-data';
}
