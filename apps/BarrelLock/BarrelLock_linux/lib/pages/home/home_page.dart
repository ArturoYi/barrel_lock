import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'password_tab_page.dart';
import 'settings_tab_page.dart';

/// 首页 Tab Shell（MVVM-C 的 V 层）。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _tabPages = <Widget>[PasswordTabPage(), SettingsTabPage()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final selectedIndex = state.selectedTabIndex;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.inversePrimary,
        title: Text(state.appName),
      ),
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
  }

  static IconData _iconForTab(HomeTab tab) {
    return switch (tab) {
      HomeTab.password => Icons.lock_outline,
      HomeTab.settings => Icons.settings_outlined,
    };
  }
}
