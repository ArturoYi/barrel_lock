import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 密码详情页（其他平台最小实现）。
class DetailPage extends ConsumerWidget {
  const DetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailViewModelProvider(id));
    final viewModel = ref.read(detailViewModelProvider(id).notifier);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.data == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: viewModel.onPop),
          title: const Text('详情'),
        ),
        body: Center(child: Text(state.errorMessage ?? '无法加载详情')),
      );
    }

    final data = state.data!;
    final descriptor = CipherTypeDescriptor.forType(data.type);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: Text(data.overview.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型：${descriptor.label}'),
            const SizedBox(height: 8),
            Text('副标题：${data.overview.subtitle}'),
          ],
        ),
      ),
    );
  }
}
