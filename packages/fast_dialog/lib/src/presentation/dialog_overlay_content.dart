import 'package:flutter/material.dart';

import '../domain/dialog_entry.dart';
import '../domain/dialog_mask.dart';
import '../domain/dialog_mode.dart';
import 'dialog_animator.dart';
import 'dialog_barrier.dart';
import 'dialog_shell.dart';

/// 单条弹窗的完整 Overlay 内容：遮罩 + 动画面板 + 交互外壳。
final class DialogOverlayContent extends StatelessWidget {
  const DialogOverlayContent({
    super.key,
    required this.entry,
    required this.animation,
    required this.onDismiss,
  });

  final DialogEntry<dynamic> entry;
  final Animation<double> animation;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final config = entry.showConfig;
    final alignment = DialogAnimator.alignmentFor(config.animation.type);

    final panel = DialogShell(
      ignoreSafeArea: config.ignoreSafeArea,
      scrollable: config.scrollable,
      enableDragDismiss: config.enableDragDismiss,
      dragDismissThreshold: config.dragDismissThreshold,
      onDragDismiss: onDismiss,
      child: entry.builder(context),
    );

    final animatedPanel = DialogAnimator.wrap(
      child: panel,
      animation: animation,
      secondaryAnimation: const AlwaysStoppedAnimation(0),
      spec: config.animation,
    );

    final showBarrier =
        config.mode == DialogMode.modal && config.mask is! DialogMaskNone;
    final barrierBlocksPointer =
        config.mode == DialogMode.modal && !config.usePenetrate;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showBarrier)
            FadeTransition(
              opacity: animation,
              child: IgnorePointer(
                ignoring: !barrierBlocksPointer,
                child: DialogBarrier(
                  mask: config.mask,
                  dismissible: config.maskDismissible && barrierBlocksPointer,
                  onDismiss: onDismiss,
                ),
              ),
            ),
          Align(
            alignment: alignment,
            child: config.mode == DialogMode.nonModal
                ? IgnorePointer(ignoring: false, child: animatedPanel)
                : animatedPanel,
          ),
        ],
      ),
    );
  }
}
