import 'package:barrel_lock_ui/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// 启动页居中图标，淡入出现。
final class LaunchScreenCenterIcon extends StatefulWidget {
  const LaunchScreenCenterIcon({super.key});

  @override
  State<LaunchScreenCenterIcon> createState() => _LaunchScreenCenterIconState();
}

class _LaunchScreenCenterIconState extends State<LaunchScreenCenterIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
      child: Assets.appIconCenter.image(width: 128, height: 128),
    );
  }
}
