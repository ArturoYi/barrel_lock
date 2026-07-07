import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 数据迁移页（MVVM-C 的 V 层）。
class DataMigrationPage extends ConsumerWidget {
  const DataMigrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(dataMigrationViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: const Text('数据迁移'),
      ),
      body: const Center(child: Text('数据迁移')),
    );
  }
}

/// 锁屏保护页（MVVM-C 的 V 层）。
class AppLockPage extends ConsumerWidget {
  const AppLockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(appLockViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: const Text('锁屏保护'),
      ),
      body: const Center(child: Text('锁屏保护')),
    );
  }
}

/// 清除所有内容页（MVVM-C 的 V 层）。
class ClearDataPage extends ConsumerWidget {
  const ClearDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(clearDataViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: const Text('清除所有内容'),
      ),
      body: const Center(child: Text('清除所有内容')),
    );
  }
}
