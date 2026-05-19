import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 同步 [Provider] 示例（T06.2）。
///
/// 适合场景：
/// - 计算得出的常量字符串 / 配置
/// - 派生只读值
/// - 注入纯函数 / DI 容器中的 service（典型 bridge：`ref.watch(loggerProvider)`）
///
/// 用法：
/// ```dart
/// final greeting = ref.watch(greetingProvider);
/// ```
final Provider<String> greetingProvider = Provider<String>(
  (ref) => 'Hello, World!',
  name: 'greetingProvider',
);
