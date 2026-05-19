import 'package:flutter/material.dart';

/// 搜索页占位。Shell 路由中第二个 tab。
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search Page (router demo)')),
    );
  }
}
