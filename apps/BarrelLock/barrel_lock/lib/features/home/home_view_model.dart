import 'package:core/core.dart';

import 'home_model.dart';
import 'home_tab.dart';

/// 首页 Shell 展示状态。
final class HomeViewState {
  const HomeViewState({
    required this.appName,
    required this.selectedTab,
    required this.tabs,
  });

  final String appName;
  final HomeTab selectedTab;
  final List<HomeTabDescriptor> tabs;

  int get selectedTabIndex => tabs.indexWhere((tab) => tab.tab == selectedTab);
}

/// 首页 Shell 状态与 Tab 编排（MVVM-C 的 VM 层）。
final class HomeViewModel extends Notifier<HomeViewState> {
  late final HomeModel _model;

  @override
  HomeViewState build() {
    _model = ref.read(homeModelProvider);
    return HomeViewState(
      appName: _model.appName,
      selectedTab: HomeTab.password,
      tabs: _model.tabs,
    );
  }

  void onTabSelected(int index) {
    if (index < 0 || index >= state.tabs.length) {
      return;
    }
    final tab = state.tabs[index].tab;
    if (tab == state.selectedTab) {
      return;
    }
    state = HomeViewState(
      appName: state.appName,
      selectedTab: tab,
      tabs: state.tabs,
    );
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeViewState>(
  HomeViewModel.new,
);
