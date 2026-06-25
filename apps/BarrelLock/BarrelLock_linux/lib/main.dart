import 'package:core/core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BazaarApp());
}

class BazaarApp extends StatelessWidget {
  const BazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

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
        child: Text(
          greeting(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
