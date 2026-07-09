import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'numeric_key_event.dart';

/// 监听物理键盘数字输入（桌面 / Web / 外接键盘），非数字键忽略。
final class NumericKeyboardListener extends StatelessWidget {
  const NumericKeyboardListener({
    super.key,
    required this.enabled,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onSubmit,
    this.onCancel,
    this.autofocus = true,
    required this.child,
  });

  final bool enabled;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool autofocus;
  final Widget child;

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!enabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    final digit = digitFromLogicalKey(key);
    if (digit != null) {
      onDigitPressed(digit);
      return KeyEventResult.handled;
    }

    if (isBackspaceOrDelete(key)) {
      onDeletePressed();
      return KeyEventResult.handled;
    }

    if (onSubmit != null && isSubmitKey(key)) {
      onSubmit!();
      return KeyEventResult.handled;
    }

    if (onCancel != null && isCancelKey(key)) {
      onCancel!();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(autofocus: autofocus, onKeyEvent: _onKeyEvent, child: child);
  }
}
