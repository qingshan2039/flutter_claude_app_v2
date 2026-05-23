import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme_extension.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/color_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/typography_tokens.dart';

/// 应用主题（T10.2）— 亮 / 暗 两套 [ThemeData]，由 Design Tokens 装配。
///
/// 用法（M13/T13.1 在 MaterialApp 接入）：
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ref.watch(themeModeProvider),
/// );
/// ```
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.brandSeed,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: <ThemeExtension<dynamic>>[
        if (isDark) AppColorsExtension.dark else AppColorsExtension.light,
      ],
    );

    return base.copyWith(
      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: TypographyTokens.semiBold,
          color: colorScheme.onSurface,
        ),
      ),
      // ── 卡片 ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: RadiusTokens.allLg),
        margin: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
      ),
      // ── 按钮（统一胶囊圆角 + 高度） ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: RadiusTokens.allMd),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: TypographyTokens.semiBold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: RadiusTokens.allMd),
        ),
      ),
      // ── 输入框 ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: RadiusTokens.allMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: RadiusTokens.allMd,
          borderSide: BorderSide.none,
        ),
      ),
      // ── 圆角对话框 / BottomSheet ──
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: RadiusTokens.allLg),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: RadiusTokens.topLg),
      ),
    );
  }
}
