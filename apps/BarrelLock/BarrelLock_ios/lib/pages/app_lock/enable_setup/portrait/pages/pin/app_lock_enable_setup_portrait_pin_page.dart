import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock/features/app_lock/overlay/pin_prompt/app_lock_pin_keypad.dart';
import 'package:barrel_lock/shared/widgets/numeric_keyboard_listener.dart';
import 'package:flutter/material.dart';

import '../../../shared/app_lock_enable_setup_pin_field.dart';
import '../../../shared/app_lock_enable_setup_pin_input_field.dart';

/// 竖屏 PageView 第一步：设置 PIN 与确认 PIN。
///
/// 纵向堆叠标题、说明、两个密码展示框、数字键盘与「下一步」按钮。
/// 外层包裹 [NumericKeyboardListener] 以支持外接键盘输入。
final class AppLockEnableSetupPortraitPinPage extends StatelessWidget {
  const AppLockEnableSetupPortraitPinPage({
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

  /// ViewModel 输出的流程状态（错误信息、遮蔽开关、忙碌态等）。
  final AppLockEnableSetupState state;

  /// 主密码缓冲，由 Host 维护。
  final String pinBuffer;

  /// 确认密码缓冲，由 Host 维护。
  final String confirmPinBuffer;

  /// 当前聚焦的输入框。
  final AppLockEnableSetupPinInputField activePinField;

  /// 当前聚焦框对应的缓冲，用于判断键盘是否已满。
  final String activePinBuffer;

  /// 数字键按下（0–9）。
  final ValueChanged<int> onDigitPressed;

  /// 退格键按下。
  final VoidCallback onDeletePressed;

  /// 清空当前聚焦框。
  final VoidCallback onClearPressed;

  /// 校验 PIN 并进入提示语步骤。
  final VoidCallback onContinueToHint;

  /// 取消整个开启验证流程。
  final VoidCallback onCancel;

  /// 切换聚焦的密码框。
  final ValueChanged<AppLockEnableSetupPinInputField> onActivePinFieldChanged;

  /// 切换主密码明文/密文。
  final VoidCallback onToggleObscurePin;

  /// 切换确认密码明文/密文。
  final VoidCallback onToggleObscureConfirmPin;

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 步骤说明
                    Text(
                      '请输入 ${AppLockPinPolicy.length} 位数字密码并再次确认',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // 主密码展示框
                    AppLockEnableSetupPinField(
                      label: '密码',
                      buffer: pinBuffer,
                      obscure: state.obscurePin,
                      isActive:
                          activePinField == AppLockEnableSetupPinInputField.pin,
                      isBusy: isBusy,
                      onTap: () => onActivePinFieldChanged(
                        AppLockEnableSetupPinInputField.pin,
                      ),
                      onToggleObscure: onToggleObscurePin,
                    ),
                    const SizedBox(height: 16),
                    // 确认密码展示框
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
                    // PIN 校验失败时的错误提示
                    if (state.errorMessage case final message?) ...[
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    // 屏幕内数字键盘
                    AppLockPinKeypad(
                      onDigitPressed: onDigitPressed,
                      onDeletePressed: onDeletePressed,
                      onClearPressed: onClearPressed,
                      enabled: !isBusy,
                      isFull: activePinBuffer.length >= AppLockPinPolicy.length,
                    ),
                    const SizedBox(height: 24),
                    // 进入提示语步骤
                    FilledButton(
                      onPressed: isBusy ? null : onContinueToHint,
                      child: const Text('下一步'),
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
