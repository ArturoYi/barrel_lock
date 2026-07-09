import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 锁屏保护设置页（MVVM-C 的 V 层）。
///
/// 本文件为占位实现，请自行补充 UI。接入方式：
///
/// ```dart
/// final state = ref.watch(appLockSettingsViewModelProvider);
/// final vm = ref.read(appLockSettingsViewModelProvider.notifier);
///
/// // 用户事件 → vm.onPop() / vm.onEnabledChanged() / vm.onOpenPinManage() 等
/// // 渲染 → state.when(loading: ..., error: ..., data: ...)
/// ```
class AppLockSettingsPage extends ConsumerWidget {
  const AppLockSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appLockSettingsViewModelProvider);
    final viewModel = ref.read(appLockSettingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: const Text('锁屏保护'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (_) => const Center(child: Text('请在此实现锁屏保护设置 UI')),
      ),
    );
  }
}
