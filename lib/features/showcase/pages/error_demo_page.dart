import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/error/error_mapper.dart';
import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M03 错误处理体系 — 可视化演示。
class ErrorDemoPage extends StatefulWidget {
  const ErrorDemoPage({super.key});

  @override
  State<ErrorDemoPage> createState() => _ErrorDemoPageState();
}

class _ErrorDemoPageState extends State<ErrorDemoPage> {
  final ErrorMapper _mapper = getIt<ErrorMapper>();
  String _mapped = '点下方按钮，把异常映射为 Failure';

  void _map(Object error) {
    final failure = _mapper.map(error);
    final label = switch (failure) {
      NetworkFailure() => 'NetworkFailure',
      ServerFailure(:final statusCode) => 'ServerFailure(status=$statusCode)',
      CacheFailure() => 'CacheFailure',
      UnauthorizedFailure() => 'UnauthorizedFailure',
      ValidationFailure(:final field) => 'ValidationFailure(field=$field)',
      UnknownFailure() => 'UnknownFailure',
    };
    setState(() {
      _mapped = '输入异常: ${error.runtimeType}\n→ Failure: $label\n→ message: ${failure.message}';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Result<T> fold 演示
    const Result<int> ok = Success<int>(42);
    const Result<int> err = Failed<int>(NetworkFailure(message: 'offline'));
    final okText = ok.fold((v) => 'Success → $v', (f) => 'Failed → ${f.message}');
    final errText = err.fold((v) => 'Success → $v', (f) => 'Failed → ${f.message}');

    return DemoScaffold(
      title: '错误处理体系',
      moduleId: 'M03',
      children: <Widget>[
        DemoSection(
          title: 'Exception → Failure（ErrorMapper）',
          description: '点按钮触发不同异常，看统一映射为领域层 Failure',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () => _map(
                      const NetworkException(message: 'timeout'),
                    ),
                    child: const Text('NetworkException'),
                  ),
                  OutlinedButton(
                    onPressed: () => _map(
                      const ServerException(
                        code: 'USER_NOT_FOUND',
                        message: 'no user',
                        statusCode: 404,
                      ),
                    ),
                    child: const Text('ServerException 404'),
                  ),
                  OutlinedButton(
                    onPressed: () => _map(
                      const ValidationException(
                        message: 'too short',
                        field: 'password',
                      ),
                    ),
                    child: const Text('ValidationException'),
                  ),
                  OutlinedButton(
                    onPressed: () => _map(const SocketException('refused')),
                    child: const Text('SocketException'),
                  ),
                  OutlinedButton(
                    onPressed: () => _map('随便一个字符串'),
                    child: const Text('未知 Object'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(_mapped),
            ],
          ),
        ),
        DemoSection(
          title: 'Result<T>.fold',
          description: 'Success / Failed 两态统一处理',
          child: Column(
            children: <Widget>[
              DemoResultRow('Success(42)', okText),
              DemoResultRow('Failed(NetworkFailure)', errText),
            ],
          ),
        ),
      ],
    );
  }
}
