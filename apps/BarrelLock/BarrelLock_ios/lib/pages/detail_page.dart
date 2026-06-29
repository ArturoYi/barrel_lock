import 'package:flutter/material.dart';

import '../router/router.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('详情页')),
      body: Center(
        child: FilledButton(
          onPressed: AppRouter.pop,
          child: const Text('返回'),
        ),
      ),
    );
  }
}
