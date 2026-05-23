/// 应用运行环境（T13.2）。
///
/// 三套环境对应三个入口（main_dev/main_staging/main_prod）。
/// [injectableName] 传给 `configureDependencies(environment:)`（M02），
/// 决定 `@dev` / `@prod` 等环境限定的依赖解析。
///
/// 注：M15/T15.1 会引入完整的 `EnvConfig` 数据类（baseUrl/flag 等）；本枚举是
/// M13 启动编排所需的最小环境标识。
enum AppEnvironment {
  dev,
  staging,
  prod;

  /// 传给 injectable 的环境名（与 `@dev`/`@prod`/`@Environment('staging')` 对齐）。
  String get injectableName => name;

  bool get isDev => this == AppEnvironment.dev;
  bool get isStaging => this == AppEnvironment.staging;
  bool get isProd => this == AppEnvironment.prod;

  /// 是否为「类生产」环境（staging + prod）：用于决定是否启用上报 / 关闭调试面板等。
  bool get isReleaseLike =>
      this == AppEnvironment.staging || this == AppEnvironment.prod;
}
