import 'dart:ui';

import 'package:flutter/material.dart';

/// 锁屏底遮罩：阻止用户操作下层 UI，不可点击关闭。
///
/// 可选 [child] 叠在遮罩之上，用于 PIN 解锁等锁屏交互。
///
/// [privacyOnly] 为 true 时仅绘制纯色底（后台隐私遮罩），跳过 [BackdropFilter]，
/// 确保 inactive 窗口内首帧即可上屏；锁屏验证时使用模糊层。
final class AppLockSessionBarrier extends StatelessWidget {
  const AppLockSessionBarrier({
    super.key,
    this.child,
    this.privacyOnly = false,
  });

  final Widget? child;

  /// 后台隐私模式：纯色遮挡，绘制成本低于 [BackdropFilter]。
  final bool privacyOnly;

  static const _privacyColor = Color(0xE6000000);
  static const _lockScrimColor = Color(0x99000000);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AbsorbPointer(
            child: privacyOnly
                ? const ColoredBox(
                    color: _privacyColor,
                    child: SizedBox.expand(),
                  )
                : ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                      child: const ColoredBox(
                        color: _lockScrimColor,
                        child: SizedBox.expand(),
                      ),
                    ),
                  ),
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}
