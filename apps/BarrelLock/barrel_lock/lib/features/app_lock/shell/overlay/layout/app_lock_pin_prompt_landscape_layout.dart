import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../app_lock_pin_prompt_panel.dart';

/// 横屏：左右分栏，左侧说明、右侧输入，避免宽屏下控件过度拉伸。
final class AppLockPinPromptLandscapeLayout extends StatelessWidget {
  const AppLockPinPromptLandscapeLayout({
    super.key,
    required this.state,
    required this.pinController,
    required this.pinFocusNode,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
    required this.onToggleObscure,
  });

  final AppLockPinPromptState state;
  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscure;

  static const _cardMaxWidth = 720.0;
  static const _horizontalPadding = 32.0;
  static const _columnGap = 32.0;
  static const _infoMinWidth = 220.0;
  static const _inputMaxWidth = 320.0;

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
                child: _LandscapeCard(
                  state: state,
                  pinController: pinController,
                  pinFocusNode: pinFocusNode,
                  isSubmitting: isSubmitting,
                  onSubmit: onSubmit,
                  onCancel: onCancel,
                  onToggleObscure: onToggleObscure,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _LandscapeCard extends StatelessWidget {
  const _LandscapeCard({
    required this.state,
    required this.pinController,
    required this.pinFocusNode,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
    required this.onToggleObscure,
  });

  final AppLockPinPromptState state;
  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: AppLockPinPromptLandscapeLayout._infoMinWidth,
                ),
                child: AppLockPinPromptHeaderSection(state: state),
              ),
            ),
            const SizedBox(width: AppLockPinPromptLandscapeLayout._columnGap),
            Expanded(
              flex: 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLockPinPromptLandscapeLayout._inputMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppLockPinPromptInputSection(
                      state: state,
                      pinController: pinController,
                      pinFocusNode: pinFocusNode,
                      isSubmitting: isSubmitting,
                      onSubmit: onSubmit,
                      onToggleObscure: onToggleObscure,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isSubmitting ? null : onCancel,
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
