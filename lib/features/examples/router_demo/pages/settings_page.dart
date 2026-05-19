import 'package:flutter/material.dart';

/// 设置页占位。Shell 路由中第三个 tab。M19/T19.4 完成后被真实业务页面替换。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page (router demo)')),
    );
  }
}
