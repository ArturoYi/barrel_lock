import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'layout/password_tab_landscape_view.dart';
import 'layout/password_tab_portrait_view.dart';

/// 首页「密码」Tab（Vault Home，MVVM-C 的 V 层）。
class PasswordTabPage extends ConsumerWidget {
  const PasswordTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(passwordTabViewModelProvider);
    final viewModel = ref.read(passwordTabViewModelProvider.notifier);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败：$error')),
      data: (state) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return switch (orientation) {
              Orientation.portrait => PasswordTabPortraitView(
                state: state,
                onSearchChanged: viewModel.onSearchChanged,
                onQuickFilterSelected: viewModel.onQuickFilterSelected,
                onVaultSelected: viewModel.onVaultSelected,
                onFolderCollapseToggled: viewModel.onFolderCollapseToggled,
                onFavoriteToggled: viewModel.onFavoriteToggled,
                onCipherTapped: viewModel.onCipherTapped,
                onAddPasswordTapped: viewModel.onAddPasswordTapped,
              ),
              Orientation.landscape => PasswordTabLandscapeView(
                state: state,
                onSearchChanged: viewModel.onSearchChanged,
                onQuickFilterSelected: viewModel.onQuickFilterSelected,
                onVaultSelected: viewModel.onVaultSelected,
                onFolderCollapseToggled: viewModel.onFolderCollapseToggled,
                onFavoriteToggled: viewModel.onFavoriteToggled,
                onCipherTapped: viewModel.onCipherTapped,
                onAddPasswordTapped: viewModel.onAddPasswordTapped,
              ),
            };
          },
        );
      },
    );
  }
}
