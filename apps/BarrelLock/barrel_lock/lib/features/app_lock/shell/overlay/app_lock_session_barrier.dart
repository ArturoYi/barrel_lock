import 'dart:ui';

import 'package:flutter/material.dart';

/// 锁屏底遮罩：阻止用户操作下层 UI，不可点击关闭。
final class AppLockSessionBarrier extends StatelessWidget {
  const AppLockSessionBarrier({super.key});

  @override
  Widget build(BuildContext context) {
    // 模糊遮罩层
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9), // 模糊强度
      child: const ModalBarrier(
        dismissible: false,
        color: Color(0x99000000), // 半透明黑叠加模糊
      ),
    );
  }
}
