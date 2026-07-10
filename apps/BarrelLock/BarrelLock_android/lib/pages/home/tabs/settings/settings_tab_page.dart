import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../settings/layout/settings_tab_landscape_view.dart';
import '../../../settings/layout/settings_tab_portrait_view.dart';

/// 首页「设置」Tab（MVVM-C 的 V 层）。
class SettingsTabPage extends ConsumerWidget {
  const SettingsTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsTabViewModelProvider);
    final viewModel = ref.read(settingsTabViewModelProvider.notifier);

    return OrientationBuilder(
      builder: (context, orientation) {
        return switch (orientation) {
          Orientation.portrait => SettingsTabPortraitView(
            state: state,
            onNavItemTap: viewModel.onNavItemTap,
          ),
          Orientation.landscape => SettingsTabLandscapeView(
            state: state,
            onSectionSelected: viewModel.onSectionSelected,
            onNavItemTap: viewModel.onNavItemTap,
          ),
        };
      },
    );
  }
}
