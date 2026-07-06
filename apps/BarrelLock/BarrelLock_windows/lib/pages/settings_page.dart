import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'settings/theme_setting_tile.dart';

/// 设置页（MVVM-C 的 V 层）。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('设置页')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const ThemeSettingTile(),
          const SizedBox(height: 32),
          Center(
            child: FilledButton(
              onPressed: viewModel.onPop,
              child: const Text('返回'),
            ),
          ),
        ],
      ),
    );
  }
}
