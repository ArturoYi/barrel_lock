import 'package:flutter/widgets.dart';

import '../domain/match/route_match.dart';

/// 带自定义过渡的 [Page]。
///
/// 对应 [CustomTransition] 策略，底层创建 [PageRoute] 并委托
/// [transitionsBuilder] 控制进出场动画。
class CustomTransitionPage extends Page<void> {
  final RouteMatch match;
  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final bool maintainState;
  final bool fullscreenDialog;
  final bool opaque;

  const CustomTransitionPage({
    required this.match,
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<void> createRoute(BuildContext context) =>
      _CustomTransitionPageRoute(this);
}

class _CustomTransitionPageRoute extends PageRoute<void> {
  _CustomTransitionPageRoute(CustomTransitionPage page)
      : super(settings: page);

  CustomTransitionPage get _page => settings as CustomTransitionPage;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => _page.opaque;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _page.transitionsBuilder(
        context,
        animation,
        secondaryAnimation,
        child,
      );
}
