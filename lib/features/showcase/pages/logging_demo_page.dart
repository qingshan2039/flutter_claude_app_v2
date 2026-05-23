import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:flutter_claude_app_v2/core/logger/log_sanitizer.dart';
import 'package:flutter_claude_app_v2/core/logger/performance_monitor.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M11 日志与监控 — 可视化演示。
class LoggingDemoPage extends StatefulWidget {
  const LoggingDemoPage({super.key});

  @override
  State<LoggingDemoPage> createState() => _LoggingDemoPageState();
}

class _LoggingDemoPageState extends State<LoggingDemoPage> {
  final AppLogger _logger = getIt<AppLogger>();
  final PerformanceMonitor _perf = getIt<PerformanceMonitor>();
  final LogSanitizer _sanitizer = const LogSanitizer();

  final TextEditingController _sanitizeCtrl = TextEditingController(
    text: 'login user alice@example.com phone 13812345678 password=p@ss token=abc',
  );
  String _perfResult = '点按钮测一次耗时';

  @override
  void dispose() {
    _sanitizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _measure() async {
    final d = await _perf.traceAsync('demo_task', () async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      return 'done';
    });
    setState(() => _perfResult = 'demo_task 完成，耗时已记录到日志（约 120ms）：$d');
  }

  @override
  Widget build(BuildContext context) {
    final sanitized = _sanitizer.sanitize(_sanitizeCtrl.text);

    return DemoScaffold(
      title: '日志与监控',
      moduleId: 'M11',
      children: <Widget>[
        DemoSection(
          title: '分级日志（输出到控制台）',
          description: 'release 仅 warning+；debug 全量。点按钮看 IDE 控制台',
          child: Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => _logger.d('debug message from showcase'),
                child: const Text('d'),
              ),
              OutlinedButton(
                onPressed: () => _logger.i('info message from showcase'),
                child: const Text('i'),
              ),
              OutlinedButton(
                onPressed: () => _logger.w('warning message from showcase'),
                child: const Text('w'),
              ),
              OutlinedButton(
                onPressed: () => _logger.e('error message',
                    error: Exception('demo'), stackTrace: StackTrace.current),
                child: const Text('e'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '敏感字段脱敏（实时）',
          description: 'email / 手机号 / password / token 自动脱敏',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _sanitizeCtrl,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: '原始日志文本'),
              ),
              const SizedBox(height: 8),
              Text('脱敏后：\n$sanitized'),
            ],
          ),
        ),
        DemoSection(
          title: '性能埋点（PerformanceMonitor）',
          description: 'traceAsync 包裹耗时操作，自动记录',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FilledButton(onPressed: _measure, child: const Text('运行并计时')),
              const SizedBox(height: 8),
              Text(_perfResult),
            ],
          ),
        ),
        const DemoSection(
          title: 'Sentry 崩溃上报',
          description: 'CrashReporter 抽象',
          child: Text('默认 NoopCrashReporter（无 DSN 零配置）；'
              '配置 SENTRY_DSN 后 bootstrap 切到 SentryCrashReporter，'
              '全局未捕获异常自动上报。'),
        ),
      ],
    );
  }
}
