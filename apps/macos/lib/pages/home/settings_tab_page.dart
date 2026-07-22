import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 首页「设置」Tab 占位（待实现横竖屏布局）。
class SettingsTabPage extends ConsumerWidget {
  const SettingsTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsTabViewModelProvider);
    return Center(child: Text(state.title));
  }
}
