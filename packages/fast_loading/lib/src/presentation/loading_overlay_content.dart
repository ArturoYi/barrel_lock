import 'package:flutter/material.dart';

import '../core/loading_controller.dart';
import '../domain/loading_config.dart';
import '../domain/loading_display_phase.dart';
import 'loading_barrier.dart';
import 'loading_widget.dart';

/// OverlayEntry 内展示的 Loading 面板，带短 fade-in。
class LoadingOverlayContent extends StatefulWidget {
  const LoadingOverlayContent({
    super.key,
    required this.config,
    required this.displayPhase,
    this.resultWidget,
    this.resultMessage,
  });

  final LoadingConfig config;
  final LoadingDisplayPhase displayPhase;
  final Widget? resultWidget;
  final String? resultMessage;

  @override
  State<LoadingOverlayContent> createState() => _LoadingOverlayContentState();
}

class _LoadingOverlayContentState extends State<LoadingOverlayContent>
    with SingleTickerProviderStateMixin {
  static const _fadeDuration = Duration(milliseconds: 150);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fadeDuration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: LoadingBarrier(
        config: widget.config,
        onBarrierTap: widget.config.dismissOnBarrierTap
            ? () => LoadingController.instance.dismiss()
            : null,
        child: LoadingWidget(
          config: widget.config,
          displayPhase: widget.displayPhase,
          resultWidget: widget.resultWidget,
          resultMessage: widget.resultMessage,
        ),
      ),
    );
  }
}
