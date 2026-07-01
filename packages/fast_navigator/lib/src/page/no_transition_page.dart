import 'package:flutter/widgets.dart';

import 'custom_transition_page.dart';

/// 零时长、无动画的 [Page]。
///
/// 对应 [NoTransition] 策略，也用于 [AppType.widgets] 默认行为。
class NoTransitionPage extends CustomTransitionPage {
  const NoTransitionPage({
    required super.match,
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
