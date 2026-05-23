/// 单条脱敏规则（T11.3）。
class RedactionRule {
  const RedactionRule({
    required this.pattern,
    required this.replace,
    this.description = '',
  });

  final RegExp pattern;

  /// 给定一个匹配，返回替换后的字符串。
  final String Function(Match match) replace;

  final String description;
}

/// 日志脱敏过滤器（T11.3）。
///
/// 在写入日志 / 上报前对消息做脱敏，避免 token / password / 手机号 / 邮箱等
/// 敏感信息落盘或上云。规则可配置（[RedactionRule] 列表）。
///
/// 用法：
/// ```dart
/// const sanitizer = LogSanitizer();
/// sanitizer.sanitize('{"password":"p@ss","name":"alice"}');
/// // → {"password":"***","name":"alice"}
/// ```
///
/// 自定义规则：
/// ```dart
/// final sanitizer = LogSanitizer(extraRules: [
///   RedactionRule(pattern: RegExp(r'card-\d+'), replace: (_) => 'card-***'),
/// ]);
/// ```
class LogSanitizer {
  const LogSanitizer({List<RedactionRule> extraRules = const <RedactionRule>[]})
    : _extraRules = extraRules;

  final List<RedactionRule> _extraRules;

  static const String redacted = '***';

  /// 默认规则集。
  static final List<RedactionRule> defaultRules = <RedactionRule>[
    // 1. JSON / kv 形式的敏感键："password":"xxx" / token=xxx
    //    注：authorization 头不在此列（值常含空格，如 "Bearer xxx"），交由规则 2 处理
    RedactionRule(
      description: 'sensitive key-value',
      pattern: RegExp(
        r'(["\x27]?(?:password|passwd|pwd|token|access_token|refresh_token|secret|api[_-]?key)["\x27]?\s*[:=]\s*)(["\x27]?)([^"\x27,}\s]+)(\2)',
        caseSensitive: false,
      ),
      replace: (m) => '${m.group(1)}${m.group(2)}$redacted${m.group(4)}',
    ),
    // 2. Bearer token（含 Authorization: Bearer xxx）
    RedactionRule(
      description: 'bearer token',
      pattern: RegExp(r'(Bearer\s+)([A-Za-z0-9\-._~+/]+=*)', caseSensitive: false),
      replace: (m) => '${m.group(1)}$redacted',
    ),
    // 3. Email → 保留首字母与域名：a***@example.com
    RedactionRule(
      description: 'email',
      pattern: RegExp(r'\b([A-Za-z0-9])[A-Za-z0-9._%+\-]*(@[A-Za-z0-9.\-]+\.[A-Za-z]{2,})'),
      replace: (m) => '${m.group(1)}$redacted${m.group(2)}',
    ),
    // 4. 手机号（7-15 位连续数字）→ 保留前 3 后 2
    RedactionRule(
      description: 'phone-like digits',
      pattern: RegExp(r'\b(\d{3})\d{2,10}(\d{2})\b'),
      replace: (m) => '${m.group(1)}****${m.group(2)}',
    ),
  ];

  /// 对 [input] 应用所有规则（默认规则 + 自定义规则）后返回脱敏字符串。
  String sanitize(String input) {
    var result = input;
    for (final rule in <RedactionRule>[...defaultRules, ..._extraRules]) {
      result = result.replaceAllMapped(rule.pattern, rule.replace);
    }
    return result;
  }
}
