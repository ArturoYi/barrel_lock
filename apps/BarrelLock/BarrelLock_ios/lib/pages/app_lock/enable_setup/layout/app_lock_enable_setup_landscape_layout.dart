import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../widgets/app_lock_enable_setup_form.dart';

/// 横屏：左说明 + 右表单。
final class AppLockEnableSetupLandscapeLayout extends StatelessWidget {
  const AppLockEnableSetupLandscapeLayout({
    super.key,
    required this.state,
    required this.pinController,
    required this.confirmPinController,
    required this.pinFocusNode,
    required this.onSubmit,
    required this.onCancel,
    required this.onToggleObscurePin,
    required this.onToggleObscureConfirmPin,
  });

  final AppLockEnableSetupState state;
  final TextEditingController pinController;
  final TextEditingController confirmPinController;
  final FocusNode pinFocusNode;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscurePin;
  final VoidCallback onToggleObscureConfirmPin;

  static const _infoMinWidth = 240.0;
  static const _inputMaxWidth = 360.0;
  static const _columnGap = 32.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.scrim.withValues(alpha: 0.45),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: _infoMinWidth,
                                maxWidth: 320,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '设置备用密码',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '开启应用保护前，请先设置 ${AppLockPinPolicy.length} 位数字密码作为兜底解锁方式。',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: _columnGap),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _inputMaxWidth,
                                  ),
                                  child: AppLockEnableSetupForm(
                                    state: state,
                                    pinController: pinController,
                                    confirmPinController: confirmPinController,
                                    pinFocusNode: pinFocusNode,
                                    onSubmit: onSubmit,
                                    onCancel: onCancel,
                                    onToggleObscurePin: onToggleObscurePin,
                                    onToggleObscureConfirmPin:
                                        onToggleObscureConfirmPin,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
