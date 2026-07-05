import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('详情页 · $id')),
      body: Center(
        child: FilledButton(onPressed: AppRouter.pop, child: const Text('返回')),
      ),
    );
  }
}
