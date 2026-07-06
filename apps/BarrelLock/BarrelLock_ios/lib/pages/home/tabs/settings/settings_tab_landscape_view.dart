import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../../../settings/theme_setting_tile.dart';

/// 设置 Tab 横屏布局。
class SettingsTabLandscapeView extends StatelessWidget {
  const SettingsTabLandscapeView({super.key, required this.state});

  final SettingsTabViewState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  state.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                const ThemeSettingTile(),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: Text(
                '横屏：设置内容左栏展示，右侧预留扩展区',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
