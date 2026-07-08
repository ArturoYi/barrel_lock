import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 备用密码管理页（MVVM-C 的 V 层）。
///
/// 本文件为占位实现，请自行补充 UI。接入方式：
///
/// ```dart
/// final state = ref.watch(appLockPinManageViewModelProvider);
/// final vm = ref.read(appLockPinManageViewModelProvider.notifier);
///
/// // 按 state.mode 切换 setup / hub / change / clear 布局
/// // 提交 → vm.savePin(pin:, confirmPin:) / vm.changePin(...) / vm.clearPin(...)
/// ```
class AppLockPinManagePage extends ConsumerWidget {
  const AppLockPinManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appLockPinManageViewModelProvider);
    final viewModel = ref.read(appLockPinManageViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: const Text('备用密码'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (data) =>
            Center(child: Text('请在此实现备用密码 UI（当前模式：${data.mode.name}）')),
      ),
    );
  }
}

/// 兼容路由装配名称。
typedef AppLockPinSetupPage = AppLockPinManagePage;
