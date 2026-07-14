import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_lock_pin_field.dart';
import '../app_lock_pin_prompt_panel.dart';

/// 竖屏：居中卡片，纵向堆叠标题与输入区。
final class AppLockPinPromptPortraitLayout extends StatelessWidget {
  const AppLockPinPromptPortraitLayout({
    super.key,
    required this.state,
    required this.pinBuffer,
    required this.isSubmitting,
    required this.onCancel,
    required this.onToggleObscure,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onRetryBiometric,
    required this.showBiometricRetry,
  });

  final AppLockPinPromptState state;
  final String pinBuffer;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscure;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onRetryBiometric;
  final bool showBiometricRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _PortraitCard(
        state: state,
        pinBuffer: pinBuffer,
        isSubmitting: isSubmitting,
        onCancel: onCancel,
        onToggleObscure: onToggleObscure,
        onDigitPressed: onDigitPressed,
        onDeletePressed: onDeletePressed,
        onRetryBiometric: onRetryBiometric,
        showBiometricRetry: showBiometricRetry,
      ),
    );
  }
}

final class _PortraitCard extends StatelessWidget {
  const _PortraitCard({
    required this.state,
    required this.pinBuffer,
    required this.isSubmitting,
    required this.onCancel,
    required this.onToggleObscure,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onRetryBiometric,
    required this.showBiometricRetry,
  });

  final AppLockPinPromptState state;
  final String pinBuffer;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscure;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onRetryBiometric;
  final bool showBiometricRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLockPinPromptHeaderSection(state: state),
                const SizedBox(height: 24),
                AppLockPinField(
                  label: '应用内密码',
                  buffer: pinBuffer,
                  obscure: state.obscurePin,
                  isActive: true,
                ),
              ],
            ),
          ),
          AppLockPinPromptInputSection(
            state: state,
            pinBuffer: pinBuffer,
            isSubmitting: isSubmitting,
            onToggleObscure: onToggleObscure,
            onDigitPressed: onDigitPressed,
            onDeletePressed: onDeletePressed,
            onRetryBiometric: onRetryBiometric,
            showBiometricRetry: showBiometricRetry,
          ),
          const Expanded(flex: 1, child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
