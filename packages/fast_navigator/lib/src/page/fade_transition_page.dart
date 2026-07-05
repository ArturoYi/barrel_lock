import 'package:flutter/widgets.dart';

import 'custom_transition_page.dart';

/// 淡入淡出 [Page]。
///
/// 对应 [FadePageTransition] 策略。
class FadeTransitionPage extends CustomTransitionPage {
  const FadeTransitionPage({
    required super.match,
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(transitionsBuilder: _transitionsBuilder);

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
