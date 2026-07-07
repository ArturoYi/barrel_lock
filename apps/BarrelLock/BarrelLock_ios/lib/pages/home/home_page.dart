import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'tabs/password/password_tab_page.dart';
import 'tabs/settings/settings_tab_page.dart';

/// 首页 Tab Shell（MVVM-C 的 V 层）。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _tabPages = <Widget>[PasswordTabPage(), SettingsTabPage()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final selectedIndex = state.selectedTabIndex;

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (isLandscape) {
          return Scaffold(
            body: Row(
              children: [
                // 横屏侧栏：使用 NavigationRail 而非自定义 Column，以便复用
                // Material 选中态、无障碍语义，以及组件内置的 SafeArea
                //（自动避开刘海 / 灵动岛 / 底部 Home Indicator 所在一侧）。
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: viewModel.onTabSelected,
                  labelType: NavigationRailLabelType.all,
                  // 默认 destinations 会挤在顶部；spaceAround 在可用高度内
                  // 均匀分布 Tab，效果类似垂直方向的 space-around。
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  destinations: [
                    for (final tab in state.tabs)
                      NavigationRailDestination(
                        icon: Icon(_iconForTab(tab.tab)),
                        label: Text(tab.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: _tabPages,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: selectedIndex, children: _tabPages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: viewModel.onTabSelected,
            destinations: [
              for (final tab in state.tabs)
                NavigationDestination(
                  icon: Icon(_iconForTab(tab.tab)),
                  label: tab.label,
                ),
            ],
          ),
        );
      },
    );
  }

  static IconData _iconForTab(HomeTab tab) {
    return switch (tab) {
      HomeTab.password => Icons.lock_outline,
      HomeTab.settings => Icons.settings_outlined,
    };
  }
}
