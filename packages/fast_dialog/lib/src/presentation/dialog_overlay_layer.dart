import 'package:flutter/material.dart';

import '../domain/dialog_entry.dart';
import 'dialog_overlay_content.dart';

/// 单条弹窗 [OverlayEntry] 的动画控制器句柄。
///
/// 由 [DialogOverlayHost] 持有，用于 refresh / dismiss 时驱动 [DialogLayer]。
final class DialogLayerHandle {
  _DialogLayerState? _state;

  void _bind(_DialogLayerState state) {
    _state = state;
  }

  void _unbind(_DialogLayerState state) {
    if (_state == state) {
      _state = null;
    }
  }

  void updateEntry(DialogEntry<dynamic> entry) {
    _state?.updateEntry(entry);
  }

  Future<void> dismiss() async {
    await _state?.dismiss();
  }
}

/// 带 [AnimationController] 的弹窗层，负责入场/退场动画与 onShow 时机。
final class DialogLayer extends StatefulWidget {
  const DialogLayer({
    super.key,
    required this.entry,
    required this.handle,
    required this.onShowComplete,
    required this.onDismiss,
  });

  final DialogEntry<dynamic> entry;
  final DialogLayerHandle handle;
  final VoidCallback onShowComplete;
  final VoidCallback onDismiss;

  @override
  State<DialogLayer> createState() => _DialogLayerState();
}

class _DialogLayerState extends State<DialogLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DialogEntry<dynamic> _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    final spec = _entry.showConfig.animation;
    _controller = AnimationController(
      duration: spec.duration,
      reverseDuration: spec.reverseDuration ?? spec.duration,
      vsync: this,
    );
    widget.handle._bind(this);
    _controller.addStatusListener(_handleAnimationStatus);
    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onShowComplete();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    widget.handle._unbind(this);
    _controller.dispose();
    super.dispose();
  }

  void updateEntry(DialogEntry<dynamic> entry) {
    setState(() => _entry = entry);
  }

  Future<void> dismiss() async {
    if (_controller.status == AnimationStatus.dismissed) {
      return;
    }
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return DialogOverlayContent(
      entry: _entry,
      animation: _controller,
      onDismiss: widget.onDismiss,
    );
  }
}
