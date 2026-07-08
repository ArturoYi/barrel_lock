import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../widgets/app_lock_enable_setup_form.dart';

/// 竖屏：局部遮罩 + 居中卡片。
final class AppLockEnableSetupPortraitLayout extends StatelessWidget {
  const AppLockEnableSetupPortraitLayout({
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

  static const _cardMaxWidth = 420.0;

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _cardMaxWidth,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('设置备用密码', style: theme.textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text(
                                '开启应用保护前，请先设置 ${AppLockPinPolicy.length} 位数字密码作为兜底解锁方式。',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppLockEnableSetupForm(
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
                            ],
                          ),
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
