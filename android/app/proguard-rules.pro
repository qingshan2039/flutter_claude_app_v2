# M16/T16.6 Android R8/ProGuard 规则（release minify 时生效）。
#
# 多数插件（sentry / permission_handler / flutter_secure_storage / path_provider
# 等）随包附带 consumer-proguard 规则，无需在此重复。下面只补 Flutter 引擎与
# 通用反射相关的 keep。

# ── Flutter 引擎 / 插件注册 ──
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── 保留行号/源文件名，便于崩溃栈还原（配合 --split-debug-info）──
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature,InnerClasses,EnclosingMethod

# ── 隐藏原始源文件名（只暴露混淆后的栈）──
-renamesourcefileattribute SourceFile

# ── 反射/序列化兜底：保留带 @Keep 的成员 ──
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
