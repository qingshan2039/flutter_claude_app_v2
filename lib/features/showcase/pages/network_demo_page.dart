import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/core/network/cancel_token_manager.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/log_interceptor.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M04 网络层 — 可视化演示。
class NetworkDemoPage extends StatefulWidget {
  const NetworkDemoPage({super.key});

  @override
  State<NetworkDemoPage> createState() => _NetworkDemoPageState();
}

class _NetworkDemoPageState extends State<NetworkDemoPage> {
  final Dio _dio = getIt<Dio>();
  final TextEditingController _sanitizeCtrl = TextEditingController(
    text: '{"user":"alice","password":"p@ss","token":"abc123"}',
  );
  String _requestResult = '点按钮发起一次请求（经全部拦截器）';
  bool _loading = false;

  @override
  void dispose() {
    _sanitizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    setState(() {
      _loading = true;
      _requestResult = '请求中…';
    });
    try {
      // 传完整 URL 覆盖 baseUrl，命中公共测试 API
      final response = await _dio.get<dynamic>(
        'https://jsonplaceholder.typicode.com/users/1',
      );
      setState(() {
        _requestResult = '✅ ${response.statusCode}\n'
            'name=${(response.data as Map)['name']}';
      });
    } on DioException catch (e) {
      // ApiErrorInterceptor 已把 DioException.error 转为 AppException
      final mapped = e.error;
      setState(() {
        _requestResult = mapped is AppException
            ? '✗ 已被 ErrorInterceptor 转换：\n'
                '${mapped.runtimeType}(code=${mapped.code})\n${mapped.message}'
            : '✗ DioException(${e.type})';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final interceptors =
        _dio.interceptors.map((i) => i.runtimeType.toString()).toList();
    final logInterceptor = LoggingInterceptor();
    final sanitized = logInterceptor.sanitizeBody(
      _safeParse(_sanitizeCtrl.text),
    );

    return DemoScaffold(
      title: '网络层',
      moduleId: 'M04',
      children: <Widget>[
        DemoSection(
          title: 'Dio 拦截器链',
          description: 'getIt<Dio>() 已装配的拦截器（按执行顺序）',
          child: Column(
            children: <Widget>[
              for (final (i, name) in interceptors.indexed)
                DemoResultRow('#$i', name),
            ],
          ),
        ),
        DemoSection(
          title: '发起真实请求（经拦截器链）',
          description: 'Auth 注入 token → Log 打印 → Retry 抖动重试 → Error 归一化',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FilledButton(
                onPressed: _loading ? null : _sendRequest,
                child: const Text('GET /users/1'),
              ),
              const SizedBox(height: 12),
              Text(_requestResult),
            ],
          ),
        ),
        DemoSection(
          title: 'LoggingInterceptor 脱敏',
          description: '编辑下方 JSON，password/token 会被实时脱敏',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _sanitizeCtrl,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: '原始 body'),
              ),
              const SizedBox(height: 8),
              Text('脱敏后：$sanitized'),
            ],
          ),
        ),
        DemoSection(
          title: 'CancelTokenManager',
          description: '页面级请求取消管理',
          child: Builder(
            builder: (context) {
              final manager = getIt<CancelTokenManager>();
              manager.acquire('demo');
              final count = manager.activeCount;
              return DemoResultRow('activeCount(acquire 后)', '$count');
            },
          ),
        ),
      ],
    );
  }

  Object? _safeParse(String text) {
    // 简单尝试当 JSON map 解析；失败则原样返回字符串
    try {
      final trimmed = text.trim();
      if (trimmed.startsWith('{')) {
        final map = <String, dynamic>{};
        final inner = trimmed.substring(1, trimmed.length - 1);
        for (final pair in inner.split(',')) {
          final kv = pair.split(':');
          if (kv.length == 2) {
            map[kv[0].trim().replaceAll('"', '')] =
                kv[1].trim().replaceAll('"', '');
          }
        }
        return map;
      }
    } catch (_) {}
    return text;
  }
}
