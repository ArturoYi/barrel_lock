import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../settings/widgets/settings_subpage_scaffold.dart';
import 'enable_setup/app_lock_enable_setup_host.dart';
import 'settings/layout/app_lock_settings_landscape_body.dart';
import 'settings/layout/app_lock_settings_portrait_body.dart';

/// 应用保护设置页（MVVM-C 的 V 层）。
class AppLockSettingsPage extends ConsumerWidget {
  const AppLockSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appLockSettingsViewModelProvider);
    final viewModel = ref.read(appLockSettingsViewModelProvider.notifier);
    final enableSetup = ref.watch(appLockEnableSetupProvider);

    final controlsLocked = state.maybeWhen(
      data: (data) => data.isLoading || enableSetup.isVisible,
      orElse: () => enableSetup.isVisible,
    );

    return SettingsSubpageScaffold(
      title: '应用保护',
      onBack: viewModel.onPop,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (data) {
          return Stack(
            fit: StackFit.expand,
            children: [
              OrientationBuilder(
                builder: (context, orientation) {
                  final bodyProps = (
                    data: data,
                    enableSetupVisible: enableSetup.isVisible,
                    onEnabledChanged: controlsLocked
                        ? null
                        : viewModel.onEnabledChanged,
                    onOpenPinManage: viewModel.onOpenPinManage,
                  );

                  return switch (orientation) {
                    Orientation.portrait => AppLockSettingsPortraitBody(
                      data: bodyProps.data,
                      enableSetupVisible: bodyProps.enableSetupVisible,
                      onEnabledChanged: bodyProps.onEnabledChanged,
                      onOpenPinManage: bodyProps.onOpenPinManage,
                    ),
                    Orientation.landscape => AppLockSettingsLandscapeBody(
                      data: bodyProps.data,
                      enableSetupVisible: bodyProps.enableSetupVisible,
                      onEnabledChanged: bodyProps.onEnabledChanged,
                      onOpenPinManage: bodyProps.onOpenPinManage,
                    ),
                  };
                },
              ),
              const AppLockEnableSetupHost(),
            ],
          );
        },
      ),
    );
  }
}
