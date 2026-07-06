import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import 'password_keypad.dart';

/// 密码 Tab 横屏布局。
class PasswordTabLandscapeView extends StatelessWidget {
  const PasswordTabLandscapeView({
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
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  Text(
                    state.maskedPin,
                    style: textTheme.headlineLarge?.copyWith(letterSpacing: 10),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '横屏：状态区与键盘左右分栏',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            PasswordKeypad(
              onDigitPressed: onDigitPressed,
              onDeletePressed: onDeletePressed,
              onClearPressed: onClearPressed,
              isComplete: state.isComplete,
            ),
          ],
        ),
      ),
    );
  }
}
