import 'package:flutter/material.dart';

import '../domain/loading_config.dart';
import '../domain/loading_display_phase.dart';
import 'loading_body_widget.dart';
import 'loading_surface_widget.dart';

/// Loading 指示器、文案与结果态内容。
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    required this.config,
    this.displayPhase = LoadingDisplayPhase.loading,
    this.resultWidget,
    this.resultMessage,
  });

  final LoadingConfig config;
  final LoadingDisplayPhase displayPhase;
  final Widget? resultWidget;
  final String? resultMessage;

  @override
  Widget build(BuildContext context) {
    final style = config.effectiveStyle;

    return LoadingSurfaceWidget(
      style: style,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          layoutBuilder: (currentChild, previousChildren) =>
              currentChild ?? const SizedBox.shrink(),
          child: KeyedSubtree(
            key: ValueKey(displayPhase),
            child: LoadingBodyWidget(
              config: config,
              displayPhase: displayPhase,
              resultWidget: resultWidget,
              resultMessage: resultMessage,
            ),
          ),
        ),
      ),
    );
  }
}
