import 'package:flutter/material.dart';

import '../domain/loading_style.dart';

/// 按 [LoadingStyle.surfaceSpec] 渲染 Material 容器。
class LoadingSurfaceWidget extends StatelessWidget {
  const LoadingSurfaceWidget({
    super.key,
    required this.style,
    required this.child,
  });

  final LoadingStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spec = style.surfaceSpec;
    final backgroundColor = style.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return Material(
      color: backgroundColor,
      elevation: spec.elevation,
      shadowColor: spec.shadowColor,
      borderRadius: BorderRadius.circular(spec.borderRadius),
      child: Padding(
        padding: spec.contentPadding,
        child: child,
      ),
    );
  }
}
