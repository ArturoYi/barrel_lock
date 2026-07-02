import 'package:flutter/material.dart';

import '../domain/loading_config.dart';
import '../domain/loading_display_phase.dart';
import '../domain/loading_style.dart';

/// 加载中 / 结果态指示器与外部传入文案；无文案时不占位。
class LoadingBodyWidget extends StatelessWidget {
  const LoadingBodyWidget({
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

    return switch (displayPhase) {
      LoadingDisplayPhase.loading => _buildLoadingBody(context, style),
      LoadingDisplayPhase.success || LoadingDisplayPhase.error =>
        resultWidget ?? _buildDefaultBody(
          context,
          style,
          indicator: _buildBuiltInResultIcon(context, style),
          message: resultMessage,
        ),
    };
  }

  Widget _buildLoadingBody(BuildContext context, LoadingStyle style) {
    if (style.loadingWidget != null) {
      return style.loadingWidget!;
    }

    return _buildDefaultBody(
      context,
      style,
      indicator: _buildIndicator(context, style),
      message: config.message,
    );
  }

  Widget _buildDefaultBody(
    BuildContext context,
    LoadingStyle style, {
    required Widget indicator,
    required String? message,
  }) {
    final messageWidget = _buildMessage(context, style, message);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        if (messageWidget != null) messageWidget,
      ],
    );
  }

  Widget _buildBuiltInResultIcon(BuildContext context, LoadingStyle style) {
    final spec = style.indicatorSpec;
    final colors = Theme.of(context).colorScheme;

    final (icon, color) = switch (displayPhase) {
      LoadingDisplayPhase.success => (Icons.check_circle, colors.primary),
      LoadingDisplayPhase.error => (Icons.error_outline, colors.error),
      LoadingDisplayPhase.loading => throw StateError('unreachable'),
    };

    return Icon(icon, size: spec.size, color: color);
  }

  Widget _buildIndicator(BuildContext context, LoadingStyle style) {
    if (style.indicator != null) {
      return style.indicator!;
    }

    final spec = style.indicatorSpec;
    final color = style.indicatorColor ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: spec.size,
      height: spec.size,
      child: CircularProgressIndicator(
        strokeWidth: spec.strokeWidth,
        color: color,
      ),
    );
  }

  Widget? _buildMessage(
    BuildContext context,
    LoadingStyle style,
    String? message,
  ) {
    if (message == null || message.isEmpty) {
      return null;
    }

    final spec = style.indicatorSpec;
    final textStyle = spec.textStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            );

    return Padding(
      padding: EdgeInsets.only(top: spec.messageSpacing),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
