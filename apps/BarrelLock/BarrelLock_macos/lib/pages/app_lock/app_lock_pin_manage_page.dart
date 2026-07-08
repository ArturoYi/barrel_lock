import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 备用密码管理页（MVVM-C 的 V 层）。
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

typedef AppLockPinSetupPage = AppLockPinManagePage;
