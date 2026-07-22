import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import 'settings_portrait_scroll_view.dart';

/// 设置 Tab 竖屏布局：SafeArea + [SettingsPortraitScrollView]。
class SettingsTabPortraitView extends StatelessWidget {
  const SettingsTabPortraitView({
    super.key,
    required this.state,
    required this.onNavItemTap,
  });

  final SettingsTabViewState state;
  final ValueChanged<String> onNavItemTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SettingsPortraitScrollView(
        state: state,
        onNavItemTap: onNavItemTap,
      ),
    );
  }
}
