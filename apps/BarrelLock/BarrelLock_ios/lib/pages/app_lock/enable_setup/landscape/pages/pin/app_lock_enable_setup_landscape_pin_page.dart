import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock/features/app_lock/overlay/pin_prompt/app_lock_pin_keypad.dart';
import 'package:barrel_lock/shared/widgets/numeric_keyboard_listener.dart';
import 'package:flutter/material.dart';

import '../../../shared/app_lock_enable_setup_pin_field.dart';
import '../../../shared/app_lock_enable_setup_pin_input_field.dart';

/// 横屏 PageView 第一步：左侧说明、右侧 PIN 输入与键盘。
///
/// 采用左右分栏布局，避免宽屏下控件过度拉伸；交互逻辑与竖屏版一致。
final class AppLockEnableSetupLandscapePinPage extends StatelessWidget {
  const AppLockEnableSetupLandscapePinPage({
    super.key,
    required this.state,
    required this.pinBuffer,
    required this.confirmPinBuffer,
    required this.activePinField,
    required this.activePinBuffer,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
    required this.onContinueToHint,
    required this.onCancel,
    required this.onActivePinFieldChanged,
    required this.onToggleObscurePin,
    required this.onToggleObscureConfirmPin,
  });

  final AppLockEnableSetupState state;
  final String pinBuffer;
  final String confirmPinBuffer;
  final AppLockEnableSetupPinInputField activePinField;
  final String activePinBuffer;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;
  final VoidCallback onContinueToHint;
  final VoidCallback onCancel;
  final ValueChanged<AppLockEnableSetupPinInputField> onActivePinFieldChanged;
  final VoidCallback onToggleObscurePin;
  final VoidCallback onToggleObscureConfirmPin;

  /// 左右栏间距。
  static const _columnGap = 32.0;

  /// 左侧说明区最小宽度，防止文字被过度压缩。
  static const _infoMinWidth = 220.0;

  /// 右侧输入区最大宽度，防止键盘与按钮在超宽屏上拉伸。
  static const _inputMaxWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = state.isBusy;

    return NumericKeyboardListener(
      enabled: !isBusy,
      onDigitPressed: onDigitPressed,
      onDeletePressed: onDeletePressed,
      onSubmit: onContinueToHint,
      onCancel: onCancel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 左侧：说明（flex 3，占更大比例）
                    Expanded(
                      flex: 3,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: _infoMinWidth,
                        ),
                        child: Text(
                          '请输入 ${AppLockPinPolicy.length} 位数字密码并再次确认',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: _columnGap),
                    // 右侧：密码框、键盘与操作按钮（flex 2，限制最大宽度）
                    Expanded(
                      flex: 2,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _inputMaxWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppLockEnableSetupPinField(
                              label: '密码',
                              buffer: pinBuffer,
                              obscure: state.obscurePin,
                              isActive:
                                  activePinField ==
                                  AppLockEnableSetupPinInputField.pin,
                              isBusy: isBusy,
                              onTap: () => onActivePinFieldChanged(
                                AppLockEnableSetupPinInputField.pin,
                              ),
                              onToggleObscure: onToggleObscurePin,
                            ),
                            const SizedBox(height: 16),
                            AppLockEnableSetupPinField(
                              label: '确认密码',
                              buffer: confirmPinBuffer,
                              obscure: state.obscureConfirmPin,
                              isActive:
                                  activePinField ==
                                  AppLockEnableSetupPinInputField.confirmPin,
                              isBusy: isBusy,
                              onTap: () => onActivePinFieldChanged(
                                AppLockEnableSetupPinInputField.confirmPin,
                              ),
                              onToggleObscure: onToggleObscureConfirmPin,
                            ),
                            if (state.errorMessage case final message?) ...[
                              const SizedBox(height: 8),
                              Text(
                                message,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            AppLockPinKeypad(
                              onDigitPressed: onDigitPressed,
                              onDeletePressed: onDeletePressed,
                              onClearPressed: onClearPressed,
                              enabled: !isBusy,
                              isFull:
                                  activePinBuffer.length >=
                                  AppLockPinPolicy.length,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: isBusy ? null : onContinueToHint,
                              child: const Text('下一步'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
