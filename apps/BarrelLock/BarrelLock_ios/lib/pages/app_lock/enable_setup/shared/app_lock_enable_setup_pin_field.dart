import 'package:flutter/material.dart';

/// 开启验证 PIN 步骤的单行密码展示框（横竖屏共用）。
///
/// 不使用系统 [TextField]，而是以自定义容器展示 PIN 缓冲内容，
/// 配合 [AppLockPinKeypad] 完成输入。支持点击切换聚焦框、切换明文/密文。
final class AppLockEnableSetupPinField extends StatelessWidget {
  const AppLockEnableSetupPinField({
    super.key,
    required this.label,
    required this.buffer,
    required this.obscure,
    required this.isActive,
    required this.isBusy,
    required this.onTap,
    required this.onToggleObscure,
  });

  /// 无障碍与 UI 展示用的字段名称，如「密码」「确认密码」。
  final String label;

  /// 当前框内已输入的原始数字字符串（未遮蔽）。
  final String buffer;

  /// 是否以圆点遮蔽显示；由 ViewModel 的 [obscurePin] / [obscureConfirmPin] 驱动。
  final bool obscure;

  /// 是否为当前聚焦的输入框；聚焦时边框加粗并使用主题色。
  final bool isActive;

  /// 是否处于提交中；为 true 时禁用点击与切换明文。
  final bool isBusy;

  /// 点击输入区域时切换聚焦到此框。
  final VoidCallback onTap;

  /// 点击眼睛图标时切换明文/密文。
  final VoidCallback onToggleObscure;

  /// 将原始 PIN 缓冲转为 UI 展示文本。
  ///
  /// [obscure] 为 true 时每位数字替换为 `●`，否则原样返回。
  static String displayPin(String buffer, bool obscure) {
    if (obscure) {
      return List.filled(buffer.length, '●').join();
    }
    return buffer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = displayPin(buffer, obscure);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 字段标签
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: label,
                value: display,
                child: GestureDetector(
                  // 提交中不允许切换聚焦框
                  onTap: isBusy ? null : onTap,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        // 聚焦框高亮，非聚焦使用 outline 色
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: isActive ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      // 空缓冲时保留占位空格，避免容器高度塌陷
                      display.isEmpty ? ' ' : display,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 明文/密文切换
            IconButton(
              onPressed: isBusy ? null : onToggleObscure,
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            ),
          ],
        ),
      ],
    );
  }
}
