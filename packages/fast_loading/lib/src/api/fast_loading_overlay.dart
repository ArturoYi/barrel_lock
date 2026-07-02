import 'package:flutter/material.dart';

import '../core/loading_controller.dart';

/// 挂载到 [MaterialApp.builder]，为 [FastLoading] 提供根 Overlay。
class FastLoadingOverlay extends StatefulWidget {
  const FastLoadingOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<FastLoadingOverlay> createState() => _FastLoadingOverlayState();
}

class _FastLoadingOverlayState extends State<FastLoadingOverlay> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_attachOverlay);
  }

  @override
  void dispose() {
    LoadingController.instance.detach();
    super.dispose();
  }

  void _attachOverlay(_) {
    if (!mounted) {
      return;
    }
    final overlayState = _overlayKey.currentState;
    if (overlayState != null) {
      LoadingController.instance.attach(overlayState);
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
