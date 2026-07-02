import 'loading_style.dart';

/// 单次 Loading 展示配置。
final class LoadingConfig {
  const LoadingConfig({
    this.message,
    this.intercepting = true,
    this.interceptRouteBack = true,
    this.dismissOnBarrierTap = false,
    this.style,
  });

  /// 外部传入的加载中文案；为 null 或空时不显示、不占位。
  final String? message;

  /// 是否拦截指针事件，默认 true（ModalBarrier 语义）。
  final bool intercepting;

  /// 是否拦截路由返回（系统返回键 / 浏览器后退），默认 true。
  final bool interceptRouteBack;

  /// 点击遮罩是否关闭 Loading，默认 false。
  final bool dismissOnBarrierTap;

  /// 视觉样式；为 null 时使用 [LoadingStyle.adaptive]。
  final LoadingStyle? style;

  LoadingStyle get effectiveStyle => style ?? LoadingStyle.adaptive();
}
