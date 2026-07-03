import 'package:flutter/material.dart';

import '../core/toast_controller.dart';

/// 挂载到 [MaterialApp.builder]，为 [FastToast] 提供根 Overlay。
class FastToastOverlay extends StatefulWidget {
  const FastToastOverlay({super.key, required this.child});

  final Widget child;

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
    ToastController.instance.detach();
    super.dispose();
  }

  void _attachOverlay(_) {
    if (!mounted) {
      return;
    }
    final overlayState = _overlayKey.currentState;
    if (overlayState != null) {
      ToastController.instance.attach(overlayState);
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
