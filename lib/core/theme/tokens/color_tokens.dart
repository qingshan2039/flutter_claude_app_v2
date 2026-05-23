import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme_extension.dart' show AppColorsExtension;

/// 颜色 Token（T10.1）— 语义化命名的原始色板。
///
/// 设计原则：
/// - 这里只放**原始常量色值**；UI 不直接引用这些常量，而是通过 [ColorScheme]
///   （M3 角色色）或 [AppColorsExtension]（业务色）间接使用
/// - `brandSeed` 喂给 `ColorScheme.fromSeed` 派生整套 M3 调色板
/// - 业务色（success/warning/info）M3 ColorScheme 没有对应角色，放 ThemeExtension
abstract final class ColorTokens {
  // ── 品牌种子色 ──────────────────────────────
  static const Color brandSeed = Color(0xFF6750A4);

  // ── 业务语义色：亮色主题 ────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF57F17);
  static const Color onWarning = Color(0xFF000000);
  static const Color info = Color(0xFF0277BD);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ── 业务语义色：暗色主题（更亮，保证暗背景对比度）──
  static const Color successDark = Color(0xFF66BB6A);
  static const Color onSuccessDark = Color(0xFF003910);
  static const Color warningDark = Color(0xFFFFB300);
  static const Color onWarningDark = Color(0xFF3E2E00);
  static const Color infoDark = Color(0xFF4FC3F7);
  static const Color onInfoDark = Color(0xFF00344D);

  // ── 中性遮罩 ────────────────────────────────
  static const Color scrim = Color(0x99000000);
}
