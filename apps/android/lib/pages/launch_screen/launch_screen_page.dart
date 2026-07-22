import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 与原生纯黑启动图衔接的 Flutter 启动页（MVVM-C 的 V 层）。
class LaunchScreenPage extends ConsumerStatefulWidget {
  const LaunchScreenPage({super.key});

  @override
  ConsumerState<LaunchScreenPage> createState() => _LaunchScreenPageState();
}

class _LaunchScreenPageState extends ConsumerState<LaunchScreenPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(launchScreenViewModelProvider.notifier).onViewAppeared();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF000000),
      child: Center(child: LaunchScreenCenterIcon()),
    );
  }
}
