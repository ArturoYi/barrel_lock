import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'router/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPStorage.init();

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
    return ThemedApp.router(routerConfig: AppRouter.routerConfig);
  }
}
