import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_lock_pin_field.dart';
import '../app_lock_pin_prompt_panel.dart';

/// 横屏：左右分栏，左侧说明与 PIN 展示、右侧键盘输入，避免宽屏下控件过度拉伸。
final class AppLockPinPromptLandscapeLayout extends StatelessWidget {
  const AppLockPinPromptLandscapeLayout({
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
      child: _LandscapeCard(
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

final class _LandscapeCard extends StatelessWidget {
  const _LandscapeCard({
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

  static const _columnGap = 32.0;
  static const _infoMinWidth = 220.0;
  static const _inputMaxWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: _infoMinWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
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
                ),
                const SizedBox(width: _columnGap),
                Expanded(
                  flex: 2,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _inputMaxWidth),
                    child: AppLockPinPromptInputSection(
                      state: state,
                      pinBuffer: pinBuffer,
                      isSubmitting: isSubmitting,
                      onToggleObscure: onToggleObscure,
                      onDigitPressed: onDigitPressed,
                      onDeletePressed: onDeletePressed,
                      onRetryBiometric: onRetryBiometric,
                      showBiometricRetry: showBiometricRetry,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
