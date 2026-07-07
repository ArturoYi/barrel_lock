import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import 'settings_landscape_split_view.dart';

/// 设置 Tab 横屏布局：SafeArea + [SettingsLandscapeSplitView]。
class SettingsTabLandscapeView extends StatelessWidget {
  const SettingsTabLandscapeView({
    super.key,
    required this.state,
    required this.onSectionSelected,
    required this.onNavItemTap,
  });

  final SettingsTabViewState state;
  final ValueChanged<SettingsSectionKind> onSectionSelected;
  final ValueChanged<String> onNavItemTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SettingsLandscapeSplitView(
        state: state,
        onSectionSelected: onSectionSelected,
        onNavItemTap: onNavItemTap,
      ),
    );
  }
}
