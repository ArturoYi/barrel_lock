import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'router/router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BazaarApp(),
    ),
  );
}

class BazaarApp extends StatelessWidget {
  const BazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.routerConfig,
    );
  }
}
