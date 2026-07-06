import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'password_tab_landscape_view.dart';
import 'password_tab_portrait_view.dart';

/// 首页「密码」Tab（MVVM-C 的 V 层）。
class PasswordTabPage extends ConsumerWidget {
  const PasswordTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passwordTabViewModelProvider);
    final viewModel = ref.read(passwordTabViewModelProvider.notifier);

    return OrientationBuilder(
      builder: (context, orientation) {
        return switch (orientation) {
          Orientation.portrait => PasswordTabPortraitView(
            state: state,
            onDigitPressed: viewModel.onDigitPressed,
            onDeletePressed: viewModel.onDeletePressed,
            onClearPressed: viewModel.onClearPressed,
          ),
          Orientation.landscape => PasswordTabLandscapeView(
            state: state,
            onDigitPressed: viewModel.onDigitPressed,
            onDeletePressed: viewModel.onDeletePressed,
            onClearPressed: viewModel.onClearPressed,
          ),
        };
      },
    );
  }
}
