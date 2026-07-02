import 'package:flutter/material.dart';

/// Loading 容器外观规格（内置默认值由 [LoadingStyle.adaptive] 提供）。
///
/// 仅包含与 [Theme] 无关的布局常量；主题色覆盖见 [LoadingStyle.backgroundColor]。
final class LoadingSurfaceSpec {
  const LoadingSurfaceSpec({
    this.elevation = 8,
    this.borderRadius = 16,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 24,
    ),
    this.shadowColor = Colors.black26,
  });

  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final Color shadowColor;

  LoadingSurfaceSpec copyWith({
    double? elevation,
    double? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    Color? shadowColor,
  }) {
    return LoadingSurfaceSpec(
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }
}
