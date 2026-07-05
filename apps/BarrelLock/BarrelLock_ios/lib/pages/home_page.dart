import 'package:core/core.dart';
import 'package:flutter/material.dart';

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
            // 示例 1：带参路径 — AppRoutes.detail(id: ...)
            FilledButton(
              onPressed: () => AppRouter.push(AppRoutes.detail(id: 'demo')),
              child: Text('路径跳转 → 详情页', style: context.typography.titleLarge),
            ),
            const SizedBox(height: 12),
            // 示例 2：命名跳转 — AppRoutes.settings.name
            FilledButton(
              onPressed: () => AppRouter.pushNamed(AppRoutes.settings.name),
              child: const Text('命名跳转 → 设置页'),
            ),
          ],
        ),
      ),
    );
  }
}
