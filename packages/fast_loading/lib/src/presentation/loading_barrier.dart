import 'package:flutter/material.dart';

import '../domain/loading_config.dart';

/// 全屏遮罩层，可选拦截点击。
class LoadingBarrier extends StatelessWidget {
  const LoadingBarrier({
    super.key,
    required this.config,
    required this.child,
    this.onBarrierTap,
  });

  final LoadingConfig config;
  final Widget child;
  final VoidCallback? onBarrierTap;

  @override
  Widget build(BuildContext context) {
    final style = config.effectiveStyle;
    final semanticsLabel = config.message ?? 'Loading';

    Widget barrier = ColoredBox(color: style.barrierColor);
    if (onBarrierTap != null) {
      barrier = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBarrierTap,
        child: barrier,
      );
    }

    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        barrier,
        Center(child: child),
      ],
    );

    if (!config.intercepting) {
      content = IgnorePointer(child: content);
    } else if (onBarrierTap == null) {
      content = AbsorbPointer(child: content);
    }

    return Semantics(
      label: semanticsLabel,
      liveRegion: true,
      child: Material(type: MaterialType.transparency, child: content),
    );
  }
}
