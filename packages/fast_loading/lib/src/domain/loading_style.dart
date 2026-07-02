import 'package:flutter/material.dart';

import 'loading_indicator_spec.dart';
import 'loading_surface_spec.dart';

export 'loading_indicator_spec.dart';
export 'loading_surface_spec.dart';

/// Loading 视觉样式。
///
/// 字段分层约定：
/// - [surfaceSpec] / [indicatorSpec]：与 [Theme] 无关的布局常量（尺寸、间距、圆角等）
/// - 顶层可空字段：主题相关覆盖（颜色、文案样式兜底前的 indicator 色等）
/// - [barrierColor]：全屏遮罩色，由 [LoadingBarrier] 消费，不属于容器 Spec
/// - Widget 字段：完全替换默认 UI 的逃生舱（[indicator]、[loadingWidget] 等）
final class LoadingStyle {
  const LoadingStyle({
    this.surfaceSpec = const LoadingSurfaceSpec(),
    this.indicatorSpec = const LoadingIndicatorSpec(),
    this.indicatorColor,
    this.barrierColor = const Color(0x66000000),
    this.backgroundColor,
    this.indicator,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
  });

  /// 内置默认样式：Material 浮层 + 圆形指示器。
  factory LoadingStyle.adaptive() => const LoadingStyle();

  /// 容器外观；presentation 层 [LoadingSurfaceWidget] 消费。
  final LoadingSurfaceSpec surfaceSpec;

  /// 指示器尺寸与文案排版；presentation 层 [LoadingBodyWidget] 消费。
  final LoadingIndicatorSpec indicatorSpec;

  /// 指示器颜色；为 null 时使用 [Theme.of] 的 primary 色。
  final Color? indicatorColor;

  /// 全屏遮罩背景色。
  final Color barrierColor;

  /// 容器背景色；为 null 时使用 [ColorScheme.surfaceContainerHighest]。
  final Color? backgroundColor;

  /// 自定义指示器；为 null 时使用 [CircularProgressIndicator]。
  final Widget? indicator;

  /// 加载中完整内容；非 null 时替代默认指示器 + 文案布局。
  final Widget? loadingWidget;

  /// 成功结果 Widget；[FastLoading.dismiss] 传入 success 时展示。
  final Widget? successWidget;

  /// 失败结果 Widget；[FastLoading.dismiss] 传入 error 时展示。
  final Widget? errorWidget;
}
