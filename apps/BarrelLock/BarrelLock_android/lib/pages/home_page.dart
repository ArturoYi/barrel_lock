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
        child: Text(
          greeting(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
