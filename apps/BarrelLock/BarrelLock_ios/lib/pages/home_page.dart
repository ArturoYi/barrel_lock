import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../router/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(greeting(), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            // 示例 1：路径跳转 — AppRouter.push(location)
            FilledButton(
              onPressed: () => AppRouter.push(AppRoutes.detailPath),
              child: Text('路径跳转 → 详情页', style: context.typography.titleLarge),
            ),
            const SizedBox(height: 12),
            // 示例 2：命名跳转 — AppRouter.pushNamed(name)
            FilledButton(
              onPressed: () => AppRouter.pushNamed(AppRoutes.settings),
              child: const Text('命名跳转 → 设置页'),
            ),
          ],
        ),
      ),
    );
  }
}
