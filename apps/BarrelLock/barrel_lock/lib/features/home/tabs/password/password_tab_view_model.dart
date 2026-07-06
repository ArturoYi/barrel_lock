import 'package:core/core.dart';

import 'password_tab_model.dart';

/// 首页「密码」Tab 展示状态。
final class PasswordTabViewState {
  const PasswordTabViewState({
    required this.title,
    required this.enteredLength,
    required this.maxPinLength,
  });

  final String title;
  final int enteredLength;
  final int maxPinLength;

  String get maskedPin =>
      List.filled(enteredLength, '●').join() +
      List.filled(maxPinLength - enteredLength, '○').join();

  bool get isComplete => enteredLength >= maxPinLength;
}

/// 首页「密码」Tab 状态与业务编排（MVVM-C 的 VM 层）。
final class PasswordTabViewModel extends Notifier<PasswordTabViewState> {
  late final PasswordTabModel _model;

  @override
  PasswordTabViewState build() {
    _model = ref.read(passwordTabModelProvider);
    return PasswordTabViewState(
      title: _model.title,
      enteredLength: 0,
      maxPinLength: _model.maxPinLength,
    );
  }

  void onDigitPressed(int _) {
    if (state.isComplete) {
      return;
    }
    state = PasswordTabViewState(
      title: state.title,
      enteredLength: state.enteredLength + 1,
      maxPinLength: state.maxPinLength,
    );
  }

  void onDeletePressed() {
    if (state.enteredLength == 0) {
      return;
    }
    state = PasswordTabViewState(
      title: state.title,
      enteredLength: state.enteredLength - 1,
      maxPinLength: state.maxPinLength,
    );
  }

  void onClearPressed() {
    if (state.enteredLength == 0) {
      return;
    }
    state = PasswordTabViewState(
      title: state.title,
      enteredLength: 0,
      maxPinLength: state.maxPinLength,
    );
  }
}

final passwordTabViewModelProvider =
    NotifierProvider<PasswordTabViewModel, PasswordTabViewState>(
      PasswordTabViewModel.new,
    );
