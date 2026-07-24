import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

/// 未匹配路由时的兜底页（404）。
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text(context.l10n.error_page_not_found)),
    );
  }
}
