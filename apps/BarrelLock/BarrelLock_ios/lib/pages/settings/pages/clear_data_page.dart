import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_subpage_scaffold.dart';

/// 清除所有内容页（MVVM-C 的 V 层）：多步确认后执行删除。
class ClearDataPage extends ConsumerWidget {
  const ClearDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clearDataViewModelProvider);
    final viewModel = ref.read(clearDataViewModelProvider.notifier);
    final colorScheme = context.colors;

    return SettingsSubpageScaffold(
      title: '清除所有内容',
      onBack: viewModel.onPop,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.stepMessage,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ..._buildActions(context, state, viewModel),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    ClearDataViewState state,
    ClearDataViewModel viewModel,
  ) {
    if (state.isBusy) {
      return const [
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 24),
      ];
    }

    return switch (state.step) {
      ClearDataStep.idle => [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.colors.error),
          onPressed: viewModel.onRequestClear,
          child: const Text('开始清除'),
        ),
      ],
      ClearDataStep.confirm1 => [
        FilledButton(
          onPressed: viewModel.onConfirmStep1,
          child: const Text('我了解风险，继续'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: viewModel.onCancel, child: const Text('取消')),
      ],
      ClearDataStep.confirm2 => [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.colors.error),
          onPressed: viewModel.onConfirmStep2,
          child: const Text('确认永久删除'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: viewModel.onCancel, child: const Text('取消')),
      ],
      ClearDataStep.clearing => [
        const Center(child: CircularProgressIndicator()),
      ],
      ClearDataStep.done => [
        FilledButton(
          onPressed: viewModel.onDoneAcknowledged,
          child: const Text('完成'),
        ),
      ],
    };
  }
}
