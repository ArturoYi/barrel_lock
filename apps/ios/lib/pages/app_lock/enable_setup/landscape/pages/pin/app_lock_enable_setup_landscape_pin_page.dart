import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock/features/app_lock/overlay/pin_prompt/app_lock_pin_keypad.dart';
import 'package:barrel_lock/shared/widgets/app_lock_pin_field.dart';
import 'package:barrel_lock/shared/widgets/numeric_keyboard_listener.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 横屏 PageView 第一步：左侧说明、右侧 PIN 输入与键盘。
///
/// 采用左右分栏布局，避免宽屏下控件过度拉伸；交互逻辑与竖屏版一致。
final class AppLockEnableSetupLandscapePinPage extends StatelessWidget {
  const AppLockEnableSetupLandscapePinPage({
    super.key,
    required this.state,
    required this.pinBuffer,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onContinueToHint,
    required this.onCancel,
    required this.onToggleObscurePin,
  });

  final AppLockEnableSetupState state;
  final String pinBuffer;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onContinueToHint;
  final VoidCallback onCancel;
  final VoidCallback onToggleObscurePin;

  /// 左右栏间距。
  static const _columnGap = 32.0;

  /// 左侧说明区最小宽度，防止文字被过度压缩。
  static const _infoMinWidth = 220.0;

  /// 右侧输入区最大宽度，防止键盘与按钮在超宽屏上拉伸。
  static const _inputMaxWidth = 360.0;

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
      onCancel: onCancel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左侧：说明（flex 3，占更大比例）
                  Expanded(
                    flex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: _infoMinWidth,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '请输入 ${AppLockPinPolicy.length} 位数字密码',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppLockPinField(
                            label: '密码',
                            buffer: pinBuffer,
                            obscure: state.obscurePin,
                            isActive: true,
                          ),
                        ],
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
                      child: AppLockPinKeypad(
                        onDigitPressed: onDigitPressed,
                        trailingKey: AppLockPinKeyAction(
                          child: const Icon(Icons.backspace_outlined),
                          onPressed: onDeletePressed,
                          semanticLabel: '删除',
                        ),
                        leadingKey: isFull
                            ? AppLockPinKeyAction(
                                child: const Icon(Icons.check),
                                onPressed: onContinueToHint,
                                semanticLabel: '确认',
                              )
                            : null,
                        enabled: !isBusy,
                        isFull: isFull,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
