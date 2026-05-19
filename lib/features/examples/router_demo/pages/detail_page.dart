import 'package:flutter/material.dart';

/// 详情页占位 — 演示 path 参数读取（T07.1 / T07.2）。
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail #$id')),
      body: Center(child: Text('Detail Page for id=$id')),
    );
  }
}
