import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/examples/eager_singleton_service.dart';
import 'package:flutter_claude_app_v2/core/di/examples/factory_service.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/utils/app_info.dart';
import 'package:flutter_claude_app_v2/features/auth/data/mappers/user_mapper.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

/// M02 依赖注入与数据建模 — 可视化演示。
class DiDemoPage extends StatefulWidget {
  const DiDemoPage({super.key});

  @override
  State<DiDemoPage> createState() => _DiDemoPageState();
}

class _DiDemoPageState extends State<DiDemoPage> {
  String _factoryLog = '点按钮解析两次 FactoryService';
  String _singletonLog = '点按钮解析两次 EagerSingletonService';

  void _resolveFactory() {
    final a = getIt<FactoryService>();
    final b = getIt<FactoryService>();
    setState(() {
      _factoryLog = 'a.createdAt=${a.createdAt.toIso8601String()}\n'
          'b.createdAt=${b.createdAt.toIso8601String()}\n'
          'identical(a,b)=${identical(a, b)}  ← factory 每次新实例';
    });
  }

  void _resolveSingleton() {
    final a = getIt<EagerSingletonService>();
    final b = getIt<EagerSingletonService>();
    setState(() {
      _singletonLog = 'a.initializedAt=${a.initializedAt.toIso8601String()}\n'
          'identical(a,b)=${identical(a, b)}  ← singleton 同一实例';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = getIt<AppInfo>();

    // freezed model + JSON 往返
    const model = UserModel(id: '1', name: 'Alice', email: 'alice@example.com');
    final json = model.toJson();
    final parsed = UserModel.fromJson(json);
    final entity = model.toEntity();

    return DemoScaffold(
      title: '依赖注入与数据建模',
      moduleId: 'M02',
      children: <Widget>[
        DemoSection(
          title: '@lazySingleton 解析',
          description: 'getIt<AppInfo>() 从 DI 容器解析单例服务',
          child: Column(
            children: <Widget>[
              DemoResultRow('AppInfo.name', appInfo.name),
              DemoResultRow('AppInfo.version', appInfo.version),
            ],
          ),
        ),
        DemoSection(
          title: '@injectable (factory) vs @singleton',
          description: '验证三种注册类型的实例生命周期差异',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FilledButton(
                onPressed: _resolveFactory,
                child: const Text('解析 FactoryService ×2'),
              ),
              const SizedBox(height: 8),
              Text(_factoryLog),
              const Divider(),
              FilledButton(
                onPressed: _resolveSingleton,
                child: const Text('解析 EagerSingletonService ×2'),
              ),
              const SizedBox(height: 8),
              Text(_singletonLog),
            ],
          ),
        ),
        DemoSection(
          title: 'freezed Model ↔ JSON ↔ Entity',
          description: 'UserModel.toJson / fromJson / toEntity（snake_case 映射）',
          child: Column(
            children: <Widget>[
              DemoResultRow('model', model.toString()),
              DemoResultRow('toJson', json.toString()),
              DemoResultRow('fromJson==model', '${parsed == model}'),
              DemoResultRow('toEntity', entity.toString()),
            ],
          ),
        ),
      ],
    );
  }
}
