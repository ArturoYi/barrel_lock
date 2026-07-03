import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/toast_position.dart';
import '../domain/toast_request.dart';
import '../domain/toast_style.dart';

/// 单条 Toast 布局：图标 + 文案。
class ToastWidget extends StatelessWidget {
  const ToastWidget({
    super.key,
    required this.message,
    required this.style,
    this.onTap,
  });

  final String message;
  final ToastStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style.icon != null) ...[style.icon!, const SizedBox(width: 8)],
        Flexible(
          child: Text(
            message,
            style: style.textStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final child = Material(
      color: style.backgroundColor ?? const Color(0xE6222B45),
      borderRadius: BorderRadius.circular(style.borderRadius),
      elevation: 4,
      child: Padding(padding: style.padding, child: content),
    );

    if (onTap == null) {
      return child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

/// OverlayEntry 内展示的单条 Toast，含定时关闭与退场回调。
class ToastOverlayContent extends StatefulWidget {
  const ToastOverlayContent({
    super.key,
    required this.request,
    required this.onDismissed,
    required this.onRegisterDismiss,
  });

  final ToastRequest request;
  final VoidCallback onDismissed;
  final void Function(VoidCallback dismiss) onRegisterDismiss;

  @override
  State<ToastOverlayContent> createState() => _ToastOverlayContentState();
}

class _ToastOverlayContentState extends State<ToastOverlayContent> {
  Timer? _autoDismissTimer;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    widget.onRegisterDismiss(_dismiss);
    _autoDismissTimer = Timer(widget.request.config.duration, _dismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissed || !mounted) {
      return;
    }
    _isDismissed = true;
    _autoDismissTimer?.cancel();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.request.config;
    final style = widget.request.resolveStyle();

    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: IgnorePointer(child: SizedBox.expand())),
        Align(
          alignment: config.position.alignment,
          child: Padding(
            padding: EdgeInsets.only(
              top: config.position.anchor == ToastPositionAnchor.top
                  ? config.position.offset.dy
                  : 0,
              bottom: config.position.anchor == ToastPositionAnchor.bottom
                  ? config.position.offset.dy
                  : 0,
              left: config.position.offset.dx > 0
                  ? config.position.offset.dx
                  : 0,
              right: config.position.offset.dx < 0
                  ? -config.position.offset.dx
                  : 0,
            ),
            child: Semantics(
              liveRegion: true,
              label: widget.request.message,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ToastWidget(
                  message: widget.request.message,
                  style: style,
                  onTap: config.dismissible ? _dismiss : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
