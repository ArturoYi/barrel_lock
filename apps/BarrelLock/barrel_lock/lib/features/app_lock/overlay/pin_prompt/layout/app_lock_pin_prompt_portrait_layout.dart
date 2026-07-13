import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../app_lock_pin_prompt_panel.dart';

/// 竖屏：居中卡片，纵向堆叠标题与输入区。
final class AppLockPinPromptPortraitLayout extends StatelessWidget {
  const AppLockPinPromptPortraitLayout({
    super.key,
    required this.state,
    required this.pinBuffer,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
    required this.onToggleObscure,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  final AppLockPinPromptState state;
  final String pinBuffer;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscure;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  static const _cardMaxWidth = 400.0;
  static const _horizontalPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                child: _PortraitCard(
                  state: state,
                  pinBuffer: pinBuffer,
                  isSubmitting: isSubmitting,
                  onSubmit: onSubmit,
                  onCancel: onCancel,
                  onToggleObscure: onToggleObscure,
                  onDigitPressed: onDigitPressed,
                  onDeletePressed: onDeletePressed,
                  onClearPressed: onClearPressed,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _PortraitCard extends StatelessWidget {
  const _PortraitCard({
    required this.state,
    required this.pinBuffer,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
    required this.onToggleObscure,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  final AppLockPinPromptState state;
  final String pinBuffer;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscure;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLockPinPromptHeaderSection(state: state),
            const SizedBox(height: 24),
            AppLockPinPromptInputSection(
              state: state,
              pinBuffer: pinBuffer,
              isSubmitting: isSubmitting,
              onSubmit: onSubmit,
              onToggleObscure: onToggleObscure,
              onDigitPressed: onDigitPressed,
              onDeletePressed: onDeletePressed,
              onClearPressed: onClearPressed,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isSubmitting ? null : onCancel,
                child: Text(
                  '取消',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
