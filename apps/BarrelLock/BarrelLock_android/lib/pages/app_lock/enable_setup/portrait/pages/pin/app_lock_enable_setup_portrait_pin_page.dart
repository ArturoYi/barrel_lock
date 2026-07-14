import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock/features/app_lock/overlay/pin_prompt/app_lock_pin_keypad.dart';
import 'package:barrel_lock/shared/widgets/app_lock_pin_field.dart';
import 'package:barrel_lock/shared/widgets/numeric_keyboard_listener.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 竖屏 PageView 第一步：设置 PIN。
///
/// 纵向堆叠标题、说明、密码展示框、数字键盘与「下一步」按钮。
/// 外层包裹 [NumericKeyboardListener] 以支持外接键盘输入。
final class AppLockEnableSetupPortraitPinPage extends StatelessWidget {
  const AppLockEnableSetupPortraitPinPage({
    super.key,
    required this.state,
    required this.pinBuffer,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
    required this.onContinueToHint,
    required this.onCancel,
    required this.onToggleObscurePin,
  });

  /// ViewModel 输出的流程状态（错误信息、遮蔽开关、忙碌态等）。
  final AppLockEnableSetupState state;

  /// 主密码缓冲，由 Host 维护。
  final String pinBuffer;

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

  /// 切换主密码明文/密文。
  final VoidCallback onToggleObscurePin;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
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
                      '请输入 ${AppLockPinPolicy.length} 位数字密码',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // 主密码展示框
                    AppLockPinField(
                      label: '密码',
                      buffer: pinBuffer,
                      obscure: state.obscurePin,
                      isActive: true,
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
                      leadingKey: AppLockPinKeyAction(
                        child: const Icon(Icons.clear),
                        onPressed: onClearPressed,
                        semanticLabel: '清除',
                      ),
                      trailingKey: AppLockPinKeyAction(
                        child: const Icon(Icons.backspace_outlined),
                        onPressed: onDeletePressed,
                        semanticLabel: '删除',
                      ),
                      enabled: !isBusy,
                      isFull: pinBuffer.length >= AppLockPinPolicy.length,
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
