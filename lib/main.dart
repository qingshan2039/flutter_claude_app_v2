import 'package:flutter_claude_app_v2/bootstrap.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';

/// 默认入口（`flutter run` 不指定 -t 时使用）。默认 dev 环境。
///
/// 显式多环境入口见 main_dev.dart / main_staging.dart / main_prod.dart：
/// ```bash
/// flutter run -t lib/main_dev.dart
/// flutter run -t lib/main_prod.dart --release
/// ```
void main() => bootstrap(AppEnvironment.dev);
