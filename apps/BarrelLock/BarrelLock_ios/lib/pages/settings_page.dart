import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'settings/layout/settings_tab_landscape_view.dart';
import 'settings/layout/settings_tab_portrait_view.dart';

/// 独立路由设置页（MVVM-C 的 V 层）。
///
/// 与首页「设置」Tab 共用同一套 Sliver 滚动布局，避免维护两套 UI。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsTabViewModelProvider);
    final viewModel = ref.read(settingsTabViewModelProvider.notifier);
    final settingsViewModel = ref.read(settingsViewModelProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          settingsViewModel.onPop();
        }
      },
      child: OrientationBuilder(
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
      ),
    );
  }
}
