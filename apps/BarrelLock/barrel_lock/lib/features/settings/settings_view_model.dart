import 'package:core/core.dart';

import 'settings_coordinator.dart';

/// 设置页状态与业务编排（MVVM-C 的 VM 层）。
final class SettingsViewModel extends Notifier<void> {
  late final SettingsCoordinator _coordinator;

  @override
  void build() {
    _coordinator = ref.read(settingsCoordinatorProvider);
  }

  void onPop() => _coordinator.pop();
}

final settingsViewModelProvider = NotifierProvider<SettingsViewModel, void>(
  SettingsViewModel.new,
);
