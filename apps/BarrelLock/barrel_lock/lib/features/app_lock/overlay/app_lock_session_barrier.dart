import 'dart:ui';

import 'package:flutter/material.dart';

/// 锁屏底遮罩：阻止用户操作下层 UI，不可点击关闭。
///
/// 可选 [child] 叠在遮罩之上，用于 PIN 解锁等锁屏交互。
final class AppLockSessionBarrier extends StatelessWidget {
  const AppLockSessionBarrier({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: const ModalBarrier(
            dismissible: false,
            color: Color(0x99000000),
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}
