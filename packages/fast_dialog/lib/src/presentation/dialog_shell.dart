import 'package:flutter/material.dart';

/// 弹窗内容外壳：安全区、滚动容器、下拉关闭手势。
///
/// [NotificationListener] 吸收内部滚动通知，防止滚动穿透到底层页面。
final class DialogShell extends StatelessWidget {
  const DialogShell({
    super.key,
    required this.child,
    this.ignoreSafeArea = false,
    this.scrollable = true,
    this.enableDragDismiss = false,
    this.dragDismissThreshold = 120,
    this.onDragDismiss,
  });

  final Widget child;
  final bool ignoreSafeArea;
  final bool scrollable;
  final bool enableDragDismiss;
  final double dragDismissThreshold;
  final VoidCallback? onDragDismiss;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: content,
      );
    }

    if (!ignoreSafeArea) {
      content = SafeArea(child: content);
    }

    if (enableDragDismiss) {
      content = _DragDismissWrapper(
        threshold: dragDismissThreshold,
        onDismiss: onDragDismiss,
        child: content,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: content,
    );
  }
}

class _DragDismissWrapper extends StatefulWidget {
  const _DragDismissWrapper({
    required this.child,
    required this.threshold,
    this.onDismiss,
  });

  final Widget child;
  final double threshold;
  final VoidCallback? onDismiss;

  @override
  State<_DragDismissWrapper> createState() => _DragDismissWrapperState();
}

class _DragDismissWrapperState extends State<_DragDismissWrapper> {
  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
        });
      },
      onVerticalDragEnd: (_) {
        if (_dragOffset > widget.threshold) {
          widget.onDismiss?.call();
        }
        setState(() => _dragOffset = 0);
      },
      child: Transform.translate(
        offset: Offset(0, _dragOffset.clamp(0, double.infinity)),
        child: widget.child,
      ),
    );
  }
}
