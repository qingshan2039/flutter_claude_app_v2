import 'package:flutter_claude_app_v2/bootstrap.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';

/// 生产环境入口（T13.2）。
///
/// ```bash
/// flutter build apk -t lib/main_prod.dart --release
/// ```
void main() => bootstrap(AppEnvironment.prod);
