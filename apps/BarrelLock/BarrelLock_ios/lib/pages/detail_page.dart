import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 详情页（MVVM-C 的 V 层）。
class DetailPage extends ConsumerWidget {
  const DetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(detailModelProvider(id));
    final viewModel = ref.read(detailViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('详情页 · $id')),
      body: Center(
        child: FilledButton(
          onPressed: viewModel.onPop,
          child: const Text('返回'),
        ),
      ),
    );
  }
}
