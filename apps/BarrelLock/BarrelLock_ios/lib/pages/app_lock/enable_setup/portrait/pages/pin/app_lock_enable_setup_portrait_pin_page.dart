import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock/features/app_lock/overlay/pin_prompt/app_lock_pin_keypad.dart';
import 'package:barrel_lock/shared/widgets/numeric_keyboard_listener.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../shared/app_lock_enable_setup_pin_field.dart';

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
    required this.onContinueToHint,
    required this.onBack,
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

  /// 校验 PIN 并进入提示语步骤。
  final VoidCallback onContinueToHint;

  /// AppBar 返回或外接键盘 Esc：取消整个开启验证流程。
  final VoidCallback onBack;

  /// 切换主密码明文/密文。
  final VoidCallback onToggleObscurePin;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isBusy = state.isBusy;
    final isFull = pinBuffer.length >= AppLockPinPolicy.length;

    return NumericKeyboardListener(
      enabled: !isBusy,
      onDigitPressed: onDigitPressed,
      onDeletePressed: onDeletePressed,
      onSubmit: onContinueToHint,
      onCancel: onBack,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 步骤说明
                const SizedBox(height: 24),
                Text(
                  '请输入 ${AppLockPinPolicy.length} 位数字密码',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // 主密码展示框
                AppLockEnableSetupPinField(
                  label: '密码',
                  buffer: pinBuffer,
                  obscure: state.obscurePin,
                  isActive: true,
                  isBusy: isBusy,
                  onToggleObscure: onToggleObscurePin,
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
                // 屏幕内数字键盘
                AppLockPinKeypad(
                  onDigitPressed: onDigitPressed,
                  leadingKey: isFull
                      ? AppLockPinKeyAction(
                          child: const Icon(Icons.check),
                          onPressed: onContinueToHint,
                          semanticLabel: '确认',
                        )
                      : null,
                  trailingKey: AppLockPinKeyAction(
                    child: const Icon(Icons.backspace_outlined),
                    onPressed: onDeletePressed,
                    semanticLabel: '删除',
                  ),
                  enabled: !isBusy,
                  isFull: isFull,
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }
}
