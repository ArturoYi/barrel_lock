import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../../../settings/theme_setting_tile.dart';

/// 设置 Tab 竖屏布局。
class SettingsTabPortraitView extends StatelessWidget {
  const SettingsTabPortraitView({super.key, required this.state});

  final SettingsTabViewState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              state.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 24),
          const ThemeSettingTile(),
        ],
      ),
    );
  }
}
