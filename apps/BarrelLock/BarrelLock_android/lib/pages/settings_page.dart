import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../router/router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置页')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const ThemeSettingTile(),
          const SizedBox(height: 32),
          Center(
            child: FilledButton(
              onPressed: AppRouter.pop,
              child: const Text('返回'),
            ),
          ),
        ],
      ),
    );
  }
}
