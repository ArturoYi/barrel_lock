import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
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

  /// 是否以圆点遮蔽显示；由 ViewModel 的 [obscurePin] 驱动。
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
    final theme = context.theme;
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
                    child: _PinDotRow(
                      buffer: buffer,
                      obscure: obscure,
                      isActive: isActive,
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

/// 6 位 PIN 圆点展示行：已填写与当前活跃位加深，未填写为浅色。
final class _PinDotRow extends StatelessWidget {
  const _PinDotRow({
    required this.buffer,
    required this.obscure,
    required this.isActive,
  });

  final String buffer;
  final bool obscure;
  final bool isActive;

  static const _dotSize = 12.0;
  static const _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final darkColor = theme.colorScheme.onSurface;
    final lightColor = theme.colorScheme.outlineVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < AppLockPinPolicy.length; i++) ...[
          if (i > 0) const SizedBox(width: _spacing),
          _buildDot(
            theme: theme,
            index: i,
            darkColor: darkColor,
            lightColor: lightColor,
          ),
        ],
      ],
    );
  }

  Widget _buildDot({
    required ThemeData theme,
    required int index,
    required Color darkColor,
    required Color lightColor,
  }) {
    final isFilled = index < buffer.length;
    final isActiveDot = isActive && index == buffer.length;
    final isHighlighted = isFilled || isActiveDot;
    final color = isHighlighted ? darkColor : lightColor;

    return SizedBox(
      width: _dotSize * 2.5,
      height: _dotSize * 2.5,
      child: Center(
        child: !obscure && isFilled
            ? Text(
                buffer[index],
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: darkColor,
                ),
              )
            : Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
      ),
    );
  }
}
