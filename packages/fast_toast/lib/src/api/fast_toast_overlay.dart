import 'package:flutter/material.dart';

import '../core/toast_controller.dart';
import '../domain/toast_overlay_layer.dart';

/// 挂载到 [MaterialApp.builder]，为 [FastToast] 提供根 Overlay。
class FastToastOverlay extends StatefulWidget {
  const FastToastOverlay({
    super.key,
    required this.child,
    this.layer = ToastOverlayLayer.normal,
  });

  final Widget child;

  /// 注册的 Overlay 层级；[ToastOverlayLayer.elevated] 需挂在更高 Widget 树上。
  final ToastOverlayLayer layer;

  @override
  State<FastToastOverlay> createState() => _FastToastOverlayState();
}

class _FastToastOverlayState extends State<FastToastOverlay> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_attachOverlay);
  }

  /// Overlay 宿主销毁时注销（如根 Widget 卸载、测试 tearDown、热重启重建树）。
  /// [ToastController.detach] 会移除当前 Entry，但保留 pending 队列，待重新 attach 后继续展示。
  @override
  void dispose() {
    ToastController.instance.detach(layer: widget.layer);
    super.dispose();
  }

  void _attachOverlay(_) {
    if (!mounted) {
      return;
    }
    final overlayState = _overlayKey.currentState;
    if (overlayState != null) {
      ToastController.instance.attach(overlayState, layer: widget.layer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Overlay(key: _overlayKey),
      ],
    );
  }
}
