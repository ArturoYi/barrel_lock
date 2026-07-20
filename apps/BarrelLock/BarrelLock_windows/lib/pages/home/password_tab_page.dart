import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 首页「密码」Tab 占位（待实现横竖屏布局）。
class PasswordTabPage extends ConsumerWidget {
  const PasswordTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(passwordTabViewModelProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败：$error')),
      data: (state) => Center(child: Text(state.title)),
    );
  }
}
