import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/color_tokens.dart';

/// 业务语义色 ThemeExtension（T10.3）。
///
/// Material 3 [ColorScheme] 只有 primary / secondary / error 等角色，没有
/// success / warning / info。把这些「业务特有」颜色放进 ThemeExtension，
/// 通过 `Theme.of(context).extension<AppColorsExtension>()!` 访问，并支持
/// 亮↔暗主题切换时的 [lerp] 平滑过渡。
///
/// 便捷访问：用 [AppColorsX] 扩展 → `context.appColors.success`。
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  /// 亮色主题业务色
  static const AppColorsExtension light = AppColorsExtension(
    success: ColorTokens.success,
    onSuccess: ColorTokens.onSuccess,
    warning: ColorTokens.warning,
    onWarning: ColorTokens.onWarning,
    info: ColorTokens.info,
    onInfo: ColorTokens.onInfo,
  );

  /// 暗色主题业务色
  static const AppColorsExtension dark = AppColorsExtension(
    success: ColorTokens.successDark,
    onSuccess: ColorTokens.onSuccessDark,
    warning: ColorTokens.warningDark,
    onWarning: ColorTokens.onWarningDark,
    info: ColorTokens.infoDark,
    onInfo: ColorTokens.onInfoDark,
  );

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppColorsExtension lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}

/// 便捷访问 [AppColorsExtension]：`context.appColors.success`。
extension AppColorsX on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
