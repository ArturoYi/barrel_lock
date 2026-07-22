import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 服务支持文档页（MVVM-C 的 V 层）。
class SupportDocumentPage extends ConsumerWidget {
  const SupportDocumentPage({super.key, required this.docId});

  final String docId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = supportDocumentViewModelProvider(docId);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: Text(state.title),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.paragraphs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return SelectableText(
              state.paragraphs[index],
              style: context.textTheme.bodyLarge?.copyWith(
                color: state.notFound
                    ? context.colors.error
                    : context.colors.onSurface,
                height: 1.5,
              ),
            );
          },
        ),
      ),
    );
  }
}
