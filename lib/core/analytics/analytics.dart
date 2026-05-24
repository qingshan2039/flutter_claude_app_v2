/// 埋点抽象层（T27.1）。
///
/// 业务只依赖本接口，具体后端（Google Analytics / 友盟 / 神策 / Firebase）由
/// `data` 层适配并经 DI 绑定。多后端可用 [CompositeAnalytics] 同时上报。
///
/// 设计：
/// - 所有方法返回 `Future<void>`（底层 SDK 多为异步），UI 侧「即发即忘」即可。
/// - 事件名 / 参数键遵循统一规范（见 `analytics_event.dart`）。
abstract class Analytics {
  /// 上报自定义事件。
  Future<void> logEvent(String name, {Map<String, Object?>? params});

  /// 上报页面浏览（PV）。
  Future<void> logScreenView(String screenName, {Map<String, Object?>? params});

  /// 设置 / 清除用户标识（登录后设、登出清）。
  Future<void> setUserId(String? id);

  /// 设置用户属性（如会员等级、渠道）。
  Future<void> setUserProperty(String name, Object? value);
}
