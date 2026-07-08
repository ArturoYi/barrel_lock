import 'package:flutter/material.dart';

/// 锁屏底遮罩：阻止用户操作下层 UI，不可点击关闭。
final class AppLockSessionBarrier extends StatelessWidget {
  const AppLockSessionBarrier({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModalBarrier(dismissible: false, color: Color(0x99000000));
  }
}
