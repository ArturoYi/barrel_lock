import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import 'password_keypad.dart';

/// 密码 Tab 竖屏布局。
class PasswordTabPortraitView extends StatelessWidget {
  const PasswordTabPortraitView({
    super.key,
    required this.state,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  final PasswordTabViewState state;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(state.title, style: textTheme.headlineSmall),
            const SizedBox(height: 32),
            Text(
              state.maskedPin,
              style: textTheme.headlineMedium?.copyWith(letterSpacing: 8),
            ),
            const Spacer(),
            PasswordKeypad(
              onDigitPressed: onDigitPressed,
              onDeletePressed: onDeletePressed,
              onClearPressed: onClearPressed,
              isComplete: state.isComplete,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
