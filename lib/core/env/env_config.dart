import 'package:flutter_claude_app_v2/core/env/app_environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// 环境配置数据类（T15.1）。
///
/// 把「随环境变化的值」收敛到一个不可变对象：每个 [AppEnvironment] 有一套
/// 非敏感**默认值**（[EnvConfig.defaults]，纯函数、可单测），再由编译期
/// `--dart-define` / `--dart-define-from-file` **覆盖**敏感/可变项
/// （[EnvConfig.resolve]，T15.3）。
///
/// 访问：
/// - UI 层：`ref.watch(envConfigProvider)`
/// - 非 widget 层：`getIt<EnvConfig>()`（在入口 [registerEnvConfig] 注册）
@immutable
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.appName,
    required this.appId,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.sentryDsn,
    this.apiKey = '',
  });

  /// 每个环境的**非敏感默认值**（纯函数，便于单测）。
  factory EnvConfig.defaults(AppEnvironment env) {
    return switch (env) {
      AppEnvironment.dev => const EnvConfig(
        environment: AppEnvironment.dev,
        appName: 'CCD Dev',
        appId: '$_baseAppId.dev',
        apiBaseUrl: 'https://dev-api.example.com',
        enableLogging: true,
        enableCrashReporting: false,
        sentryDsn: '',
      ),
      AppEnvironment.staging => const EnvConfig(
        environment: AppEnvironment.staging,
        appName: 'CCD Staging',
        appId: '$_baseAppId.staging',
        apiBaseUrl: 'https://staging-api.example.com',
        enableLogging: true,
        enableCrashReporting: true,
        sentryDsn: '',
      ),
      AppEnvironment.prod => const EnvConfig(
        environment: AppEnvironment.prod,
        appName: 'CCD',
        appId: _baseAppId,
        apiBaseUrl: 'https://api.example.com',
        enableLogging: false,
        enableCrashReporting: true,
        sentryDsn: '',
      ),
    };
  }

  /// 在默认值基础上应用编译期 dart-define 覆盖（T15.3）。
  ///
  /// 支持的键：`API_BASE_URL`、`SENTRY_DSN`、`APP_KEY`/`API_KEY`、`APP_NAME`、
  /// `ENABLE_LOGGING`(bool)、`ENABLE_CRASH_REPORTING`(bool)。未提供的键保留环境默认值。
  factory EnvConfig.resolve(AppEnvironment env) {
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const apiKey = String.fromEnvironment('API_KEY');
    const appName = String.fromEnvironment('APP_NAME');
    const hasLogging = bool.hasEnvironment('ENABLE_LOGGING');
    const logging = bool.fromEnvironment('ENABLE_LOGGING');
    const hasCrash = bool.hasEnvironment('ENABLE_CRASH_REPORTING');
    const crash = bool.fromEnvironment('ENABLE_CRASH_REPORTING');

    final d = EnvConfig.defaults(env);
    return d.copyWith(
      apiBaseUrl: apiBaseUrl.isEmpty ? null : apiBaseUrl,
      sentryDsn: sentryDsn.isEmpty ? null : sentryDsn,
      apiKey: apiKey.isEmpty ? null : apiKey,
      appName: appName.isEmpty ? null : appName,
      // 注意：勿用 avoid_redundant_argument_values 自动「精简」这两行——
      // 无 dart-define 构建时 hasLogging/hasCrash 会 const 折叠为 false，
      // 三元式折叠成 null（= copyWith 默认值）而被误删，导致带 define 的构建
      // 静默丢失覆盖。该规则已在 analysis_options.yaml 关闭。
      enableLogging: hasLogging ? logging : null,
      enableCrashReporting: hasCrash ? crash : null,
    );
  }

  /// 运行环境标识。
  final AppEnvironment environment;

  /// 应用显示名（与 flavor 的 appName 对齐）。
  final String appName;

  /// 应用包名 / Bundle Id（与 flavor 的 applicationId 对齐，信息用途）。
  final String appId;

  /// API 根地址（敏感/可变，建议走 dart-define-from-file）。
  final String apiBaseUrl;

  /// 是否输出日志（dev/staging 开，prod 关）。
  final bool enableLogging;

  /// 是否上报崩溃（dev 关，staging/prod 开）。
  final bool enableCrashReporting;

  /// Sentry DSN（敏感，必须走 dart-define，不入代码库）。
  final String sentryDsn;

  /// 第三方 API Key（敏感，必须走 dart-define，不入代码库；T18.1）。
  final String apiKey;

  static const String _baseAppId =
      'com.ben.claude_flutter_v2.flutter_claude_app_v2';

  EnvConfig copyWith({
    AppEnvironment? environment,
    String? appName,
    String? appId,
    String? apiBaseUrl,
    bool? enableLogging,
    bool? enableCrashReporting,
    String? sentryDsn,
    String? apiKey,
  }) {
    return EnvConfig(
      environment: environment ?? this.environment,
      appName: appName ?? this.appName,
      appId: appId ?? this.appId,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      enableLogging: enableLogging ?? this.enableLogging,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      sentryDsn: sentryDsn ?? this.sentryDsn,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  /// 是否配置了 Sentry DSN（决定是否启用真实上报）。
  bool get hasSentryDsn => sentryDsn.isNotEmpty;

  /// 是否配置了 API Key。
  bool get hasApiKey => apiKey.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is EnvConfig &&
      other.environment == environment &&
      other.appName == appName &&
      other.appId == appId &&
      other.apiBaseUrl == apiBaseUrl &&
      other.enableLogging == enableLogging &&
      other.enableCrashReporting == enableCrashReporting &&
      other.sentryDsn == sentryDsn &&
      other.apiKey == apiKey;

  @override
  int get hashCode => Object.hash(
    environment,
    appName,
    appId,
    apiBaseUrl,
    enableLogging,
    enableCrashReporting,
    sentryDsn,
    apiKey,
  );

  /// 注意：[sentryDsn]、[apiKey] 脱敏，避免日志泄露。
  @override
  String toString() =>
      'EnvConfig(${environment.name}, appName: $appName, appId: $appId, '
      'apiBaseUrl: $apiBaseUrl, logging: $enableLogging, '
      'crash: $enableCrashReporting, sentryDsn: ${hasSentryDsn ? '***' : '(none)'}, '
      'apiKey: ${hasApiKey ? '***' : '(none)'})';
}

/// 当前环境配置（T15.1）。
///
/// 默认 dev 默认值；各入口（bootstrap / main_showcase）用
/// `overrideWithValue(EnvConfig.resolve(env))` 覆盖为真实环境。
final Provider<EnvConfig> envConfigProvider = Provider<EnvConfig>(
  (ref) => EnvConfig.defaults(AppEnvironment.dev),
  name: 'envConfigProvider',
);
