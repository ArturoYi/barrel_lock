import 'package:core/core.dart';

import 'clear_data_coordinator.dart';
import 'clear_data_model.dart';

/// 清除数据页展示状态。
final class ClearDataViewState {
  const ClearDataViewState({required this.step, required this.isBusy});

  final ClearDataStep step;
  final bool isBusy;

  String get stepMessage {
    return switch (step) {
      ClearDataStep.idle => '此操作将永久删除所有密码，且无法恢复。',
      ClearDataStep.confirm1 => '请再次确认：确定要清除所有内容吗？',
      ClearDataStep.confirm2 => '最后一次确认：删除后无法撤销。',
      ClearDataStep.clearing => '正在清除…',
      ClearDataStep.done => '所有密码已清除。',
    };
  }
}

/// 清除数据页状态与业务编排（MVVM-C 的 VM 层）。
final class ClearDataViewModel extends Notifier<ClearDataViewState> {
  late final ClearDataModel _model;
  late final ClearDataCoordinator _coordinator;

  @override
  ClearDataViewState build() {
    _model = ref.read(clearDataModelProvider);
    _coordinator = ref.read(clearDataCoordinatorProvider);
    return const ClearDataViewState(step: ClearDataStep.idle, isBusy: false);
  }

  void onPop() {
    if (state.isBusy) {
      return;
    }
    _coordinator.pop();
  }

  void onRequestClear() {
    if (state.isBusy) {
      return;
    }
    state = const ClearDataViewState(
      step: ClearDataStep.confirm1,
      isBusy: false,
    );
  }

  void onConfirmStep1() {
    state = const ClearDataViewState(
      step: ClearDataStep.confirm2,
      isBusy: false,
    );
  }

  void onCancel() {
    if (state.isBusy) {
      return;
    }
    state = const ClearDataViewState(step: ClearDataStep.idle, isBusy: false);
  }

  Future<void> onConfirmStep2() async {
    state = const ClearDataViewState(
      step: ClearDataStep.clearing,
      isBusy: true,
    );
    await _model.wipeAllPasswords();
    state = const ClearDataViewState(step: ClearDataStep.done, isBusy: false);
  }

  void onDoneAcknowledged() => _coordinator.popToHome();
}

final clearDataViewModelProvider =
    NotifierProvider<ClearDataViewModel, ClearDataViewState>(
      ClearDataViewModel.new,
    );
