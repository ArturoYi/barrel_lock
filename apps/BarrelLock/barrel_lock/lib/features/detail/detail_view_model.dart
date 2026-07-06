import 'package:core/core.dart';

import 'detail_coordinator.dart';

/// 详情页状态与业务编排（MVVM-C 的 VM 层）。
final class DetailViewModel extends Notifier<void> {
  late final DetailCoordinator _coordinator;

  @override
  void build() {
    _coordinator = ref.read(detailCoordinatorProvider);
  }

  void onPop() => _coordinator.pop();
}

final detailViewModelProvider = NotifierProvider<DetailViewModel, void>(
  DetailViewModel.new,
);
