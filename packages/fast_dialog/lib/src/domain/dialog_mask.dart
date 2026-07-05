import 'package:flutter/material.dart';

/// 遮罩层样式（sealed，便于模式匹配扩展）。
sealed class DialogMask {
  const DialogMask();
}

/// 无遮罩（非模态或自定义场景）。
final class DialogMaskNone extends DialogMask {
  const DialogMaskNone();
}

/// 半透明纯色遮罩，默认 35% 黑。
final class DialogMaskColor extends DialogMask {
  const DialogMaskColor({this.color = const Color(0x59000000)});

  final Color color;
}

/// 高斯模糊遮罩，由 [DialogBarrier] 通过 [BackdropFilter] 渲染。
final class DialogMaskBlur extends DialogMask {
  const DialogMaskBlur({this.sigma = 8, this.tint = const Color(0x33000000)});

  final double sigma;
  final Color tint;
}
