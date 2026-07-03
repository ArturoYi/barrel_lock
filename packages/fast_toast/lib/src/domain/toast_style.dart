import 'package:flutter/material.dart';

import 'toast_type.dart';

/// Toast 视觉样式。
final class ToastStyle {
  const ToastStyle({
    this.backgroundColor,
    this.textStyle,
    this.borderRadius = 8,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  factory ToastStyle.success({TextStyle? textStyle}) {
    return ToastStyle(
      backgroundColor: const Color(0xE6222B45),
      textStyle:
          textStyle ?? const TextStyle(color: Colors.white, fontSize: 14),
      icon: const Icon(
        Icons.check_circle_outline,
        color: Color(0xFF4CAF50),
        size: 20,
      ),
    );
  }

  factory ToastStyle.error({TextStyle? textStyle}) {
    return ToastStyle(
      backgroundColor: const Color(0xE6222B45),
      textStyle:
          textStyle ?? const TextStyle(color: Colors.white, fontSize: 14),
      icon: const Icon(Icons.error_outline, color: Color(0xFFEF5350), size: 20),
    );
  }

  factory ToastStyle.info({TextStyle? textStyle}) {
    return ToastStyle(
      backgroundColor: const Color(0xE6222B45),
      textStyle:
          textStyle ?? const TextStyle(color: Colors.white, fontSize: 14),
      icon: const Icon(Icons.info_outline, color: Color(0xFF42A5F5), size: 20),
    );
  }

  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final Widget? icon;
  final EdgeInsetsGeometry padding;

  /// 按 [ToastType] 解析默认样式；[custom] 使用中性样式。
  static ToastStyle forType(ToastType type, {TextStyle? textStyle}) {
    return switch (type) {
      ToastType.success => ToastStyle.success(textStyle: textStyle),
      ToastType.error => ToastStyle.error(textStyle: textStyle),
      ToastType.info => ToastStyle.info(textStyle: textStyle),
      ToastType.custom => ToastStyle(
        backgroundColor: const Color(0xE6222B45),
        textStyle:
            textStyle ?? const TextStyle(color: Colors.white, fontSize: 14),
      ),
    };
  }
}
