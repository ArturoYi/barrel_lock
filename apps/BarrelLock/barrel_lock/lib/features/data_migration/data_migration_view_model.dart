import 'package:core/core.dart';

import 'data_migration_coordinator.dart';
import 'data_migration_model.dart';

/// 数据迁移页展示状态。
final class DataMigrationViewState {
  const DataMigrationViewState({required this.actions});

  final List<DataMigrationAction> actions;
}

/// 数据迁移页状态与业务编排（MVVM-C 的 VM 层）。
final class DataMigrationViewModel extends Notifier<DataMigrationViewState> {
  late final DataMigrationModel _model;
  late final DataMigrationCoordinator _coordinator;

  @override
  DataMigrationViewState build() {
    _model = ref.read(dataMigrationModelProvider);
    _coordinator = ref.read(dataMigrationCoordinatorProvider);
    return DataMigrationViewState(actions: _model.actions);
  }

  void onPop() => _coordinator.pop();

  void onActionTap(String actionId) {
    FastToast.show('「$actionId」功能开发中');
  }
}

final dataMigrationViewModelProvider =
    NotifierProvider<DataMigrationViewModel, DataMigrationViewState>(
      DataMigrationViewModel.new,
    );
