import 'package:flutter/widgets.dart';

/// 未匹配路由时的兜底页（404）。
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text('404 — Page not found')),
    );
  }
}
