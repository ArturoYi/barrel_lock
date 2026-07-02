import 'package:flutter/material.dart';

/// Loading 指示器与文案排版规格。
///
/// 布局常量与文案样式见本类；指示器颜色覆盖见 [LoadingStyle.indicatorColor]。
final class LoadingIndicatorSpec {
  const LoadingIndicatorSpec({
    this.size = 36,
    this.strokeWidth = 3,
    this.messageSpacing = 16,
    this.textStyle,
  });

  final double size;
  final double strokeWidth;
  final double messageSpacing;

  /// 文案样式；为 null 时使用 [Theme.of] 的 bodyMedium + onSurface。
  final TextStyle? textStyle;

  LoadingIndicatorSpec copyWith({
    double? size,
    double? strokeWidth,
    double? messageSpacing,
    TextStyle? textStyle,
  }) {
    return LoadingIndicatorSpec(
      size: size ?? this.size,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      messageSpacing: messageSpacing ?? this.messageSpacing,
      textStyle: textStyle ?? this.textStyle,
    );
  }
}
