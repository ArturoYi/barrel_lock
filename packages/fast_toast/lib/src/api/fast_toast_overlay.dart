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
