import 'package:flutter/widgets.dart';

import '../domain/match/route_match.dart';
import '../domain/transition/page_transition.dart';
import 'app_type_detector.dart';
import 'cupertino_page_adapter.dart';
import 'custom_transition_page.dart';
import 'material_page_adapter.dart';
import 'fade_transition_page.dart';
import 'no_transition_page.dart';

/// 将 [RouteMatch] 解析为 Navigator 2.0 [Page] 的统一工厂。
///
/// 解析链：
/// 1. `match.route.transition`（路由级）
/// 2. [defaultTransition]（全局级，默认 [PlatformAdaptiveTransition]）
/// 3. 按策略产出 MaterialPage / CupertinoPage / NoTransitionPage / FadeTransitionPage / CustomTransitionPage
class PageFactory {
  const PageFactory({
    this.defaultTransition = const PlatformAdaptiveTransition(),
    this.appTypeOverride,
  });

  /// 全局默认过渡策略。
  final PageTransition defaultTransition;

  /// 强制指定 App 类型（单测注入，跳过 Widget 树探测）。
  final AppType? appTypeOverride;

  Page<Object?> build({
    required BuildContext context,
    required RouteMatch match,
  }) {
    final transition = match.route.transition ?? defaultTransition;
    final child = match.route.builder(context, match);

    return switch (transition) {
      PlatformAdaptiveTransition() => _buildPlatformAdaptive(
        context,
        match,
        child,
      ),
      MaterialTransition() => MaterialPageAdapter.build(
        match: match,
        child: child,
      ),
      CupertinoTransition() => CupertinoPageAdapter.build(
        match: match,
        child: child,
      ),
      NoTransition() => NoTransitionPage(
        match: match,
        key: ValueKey(match.key),
        name: match.route.name,
        arguments: match.parameters,
        child: child,
      ),
      FadePageTransition(
        :final transitionDuration,
        :final reverseTransitionDuration,
      ) =>
        FadeTransitionPage(
          match: match,
          key: ValueKey(match.key),
          name: match.route.name,
          arguments: match.parameters,
          child: child,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
        ),
      CustomTransition(
        :final transitionsBuilder,
        :final transitionDuration,
        :final reverseTransitionDuration,
        :final maintainState,
        :final fullscreenDialog,
        :final opaque,
      ) =>
        CustomTransitionPage(
          match: match,
          key: ValueKey(match.key),
          name: match.route.name,
          arguments: match.parameters,
          child: child,
          transitionsBuilder: transitionsBuilder,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
        ),
    };
  }

  Page<Object?> _buildPlatformAdaptive(
    BuildContext context,
    RouteMatch match,
    Widget child,
  ) {
    return switch (AppTypeDetector.detect(context, override: appTypeOverride)) {
      AppType.material => MaterialPageAdapter.build(match: match, child: child),
      AppType.cupertino => CupertinoPageAdapter.build(
        match: match,
        child: child,
      ),
      AppType.widgets => NoTransitionPage(
        match: match,
        key: ValueKey(match.key),
        name: match.route.name,
        arguments: match.parameters,
        child: child,
      ),
    };
  }
}
