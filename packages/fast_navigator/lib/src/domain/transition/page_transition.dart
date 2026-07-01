import 'package:flutter/widgets.dart';

/// 页面过渡策略（sealed，编译期穷举）。
///
/// 由 [PageFactory] 解析为具体 [Page]：
/// - [PlatformAdaptiveTransition] → 按 App 类型自动选择
/// - [MaterialTransition] → [MaterialPage]
/// - [CupertinoTransition] → [CupertinoPage]
/// - [NoTransition] → 零时长无动画
/// - [CustomTransition] → 用户自定义 [transitionsBuilder]
sealed class PageTransition {
  const PageTransition();
}

/// 跟随 App 类型自动选择（默认策略）。
final class PlatformAdaptiveTransition extends PageTransition {
  const PlatformAdaptiveTransition();
}

/// 显式使用 Material 平台过渡。
final class MaterialTransition extends PageTransition {
  const MaterialTransition();
}

/// 显式使用 Cupertino 平台过渡。
final class CupertinoTransition extends PageTransition {
  const CupertinoTransition();
}

/// 无过渡动画。
final class NoTransition extends PageTransition {
  const NoTransition();
}

/// 自定义过渡动画。
final class CustomTransition extends PageTransition {
  const CustomTransition({
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
  });

  final RouteTransitionsBuilder transitionsBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final bool maintainState;
  final bool fullscreenDialog;
  final bool opaque;
}
