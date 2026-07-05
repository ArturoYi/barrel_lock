import 'package:core/core.dart';

import 'launch_screen_coordinator.dart';
import 'launch_screen_model.dart';

/// 启动页状态与业务编排（MVVM-C 的 VM 层）。
final class LaunchScreenViewModel extends Notifier<void> {
  late final LaunchScreenModel _model;
  late final LaunchScreenCoordinator _coordinator;

  @override
  void build() {
    _model = ref.read(launchScreenModelProvider);
    _coordinator = ref.read(launchScreenCoordinatorProvider);
  }

  Future<void> onViewAppeared() async {
    await _model.prepare();
    _coordinator.goToHome();
  }
}

final launchScreenViewModelProvider =
    NotifierProvider<LaunchScreenViewModel, void>(LaunchScreenViewModel.new);
