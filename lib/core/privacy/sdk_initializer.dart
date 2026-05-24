import 'package:injectable/injectable.dart';

/// SDK 分级（T24.2）。
enum SdkTier {
  /// 必要 SDK：App 运行所必需（崩溃兜底、存储等），可在同意前初始化。
  essential,

  /// 可选 SDK：统计/广告/推送等涉及个人信息，**须用户同意后**才初始化。
  optional,
}

/// 一个可初始化的 SDK 组件（T24.2）。
class SdkComponent {
  const SdkComponent({
    required this.name,
    required this.tier,
    required this.init,
  });

  final String name;
  final SdkTier tier;
  final Future<void> Function() init;
}

/// SDK 初始化分级框架（T24.2）。
///
/// 合规要点：用户**同意隐私政策前**只初始化必要 SDK（[SdkTier.essential]）；
/// 可选 SDK（[SdkTier.optional]，如统计/广告）必须在用户同意后才初始化。
///
/// 用法：在 bootstrap 注册组件，拿到同意状态后调用 [initialize]。
/// ```dart
/// final init = getIt<SdkInitializer>()
///   ..register(SdkComponent(name: 'crash', tier: SdkTier.essential, init: ...))
///   ..register(SdkComponent(name: 'analytics', tier: SdkTier.optional, init: ...));
/// await init.initialize(consentGranted: consent.hasAgreed(version));
/// ```
@lazySingleton
class SdkInitializer {
  final List<SdkComponent> _components = <SdkComponent>[];
  final Set<String> _initialized = <String>{};

  /// 已注册组件（只读）。
  List<SdkComponent> get components => List<SdkComponent>.unmodifiable(_components);

  /// 已初始化组件名（只读）。
  Set<String> get initialized => Set<String>.unmodifiable(_initialized);

  /// 注册一个 SDK 组件（配合级联 `..register(...)` 使用）。
  void register(SdkComponent component) => _components.add(component);

  /// 按分级初始化：必要 SDK 总是初始化；可选 SDK 仅在 [consentGranted] 时初始化。
  /// 已初始化的组件不会重复初始化。返回**本次**初始化的组件名列表。
  Future<List<String>> initialize({required bool consentGranted}) async {
    final justInitialized = <String>[];
    for (final component in _components) {
      if (_initialized.contains(component.name)) continue;
      final allowed =
          component.tier == SdkTier.essential || consentGranted;
      if (!allowed) continue;
      await component.init();
      _initialized.add(component.name);
      justInitialized.add(component.name);
    }
    return justInitialized;
  }

  /// 重置（主要用于测试）。
  void reset() {
    _components.clear();
    _initialized.clear();
  }
}
