import 'package:core/core.dart';

import 'settings_tab_model.dart';

/// 首页「设置」Tab 展示状态。
final class SettingsTabViewState {
  const SettingsTabViewState({required this.title});

  final String title;
}

/// 首页「设置」Tab 状态与业务编排（MVVM-C 的 VM 层）。
final class SettingsTabViewModel extends Notifier<SettingsTabViewState> {
  late final SettingsTabModel _model;

  @override
  SettingsTabViewState build() {
    _model = ref.read(settingsTabModelProvider);
    return SettingsTabViewState(title: _model.title);
  }
}

final settingsTabViewModelProvider =
    NotifierProvider<SettingsTabViewModel, SettingsTabViewState>(
      SettingsTabViewModel.new,
    );
