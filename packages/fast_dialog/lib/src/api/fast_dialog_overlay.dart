import 'package:flutter/material.dart';

import '../core/dialog_manager.dart';
import '../domain/dialog_config.dart';

/// 挂载到 [MaterialApp.builder]，为 [FastDialog] 提供根 [OverlayState]。
///
/// ## 层级约定（自底向上）
///
/// ```
/// Navigator 页面
///   → FastDialogOverlay（本组件）
///   → FastToastOverlay
///   → FastLoadingOverlay
/// ```
///
/// Dialog 位于 Toast / Loading 之下，避免遮挡全局 Loading。
///
/// ## 生命周期
///
/// - [initState]：注册 [DialogConfig] 并在首帧后 [DialogManager.attach]
/// - [dispose]：[DialogManager.detach]，防止 Overlay 泄漏
final class FastDialogOverlay extends StatefulWidget {
  const FastDialogOverlay({
    super.key,
    required this.child,
    this.config = const DialogConfig(),
  });

  final Widget child;

  /// 全局默认弹窗配置，可通过 [DialogShowConfig] 在单次 show 时覆盖。
  final DialogConfig config;

  @override
  State<FastDialogOverlay> createState() => _FastDialogOverlayState();
}

class _FastDialogOverlayState extends State<FastDialogOverlay> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    super.initState();
    DialogManager.instance.configure(widget.config);
    WidgetsBinding.instance.addPostFrameCallback(_attachOverlay);
  }

  @override
  void didUpdateWidget(covariant FastDialogOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      DialogManager.instance.configure(widget.config);
    }
  }

  @override
  void dispose() {
    DialogManager.instance.detach();
    super.dispose();
  }

  void _attachOverlay(_) {
    if (!mounted) {
      return;
    }
    final overlayState = _overlayKey.currentState;
    if (overlayState != null) {
      DialogManager.instance.attach(overlayState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        // 独立 Overlay 层：Dialog Entry 插入此处，不污染 Navigator Overlay。
        Overlay(key: _overlayKey),
      ],
    );
  }
}
