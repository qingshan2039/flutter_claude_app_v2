import 'package:flutter_claude_app_v2/bootstrap.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';

/// 预发布环境入口（T13.2）。
///
/// ```bash
/// flutter run -t lib/main_staging.dart
/// ```
void main() => bootstrap(AppEnvironment.staging);
