import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 自定义 PIN 展示框（横竖屏、开启验证与 Overlay 解锁共用）。
///
/// 不使用系统 [TextField]，以圆点行展示 PIN 缓冲内容，
/// 配合 [AppLockPinKeypad] 完成输入。
final class AppLockPinField extends StatelessWidget {
  const AppLockPinField({
    super.key,
    required this.label,
    required this.buffer,
    required this.obscure,
    required this.isActive,
  });

  /// 无障碍与 UI 展示用的字段名称，如「密码」「确认密码」。
  final String label;

  /// 当前框内已输入的原始数字字符串（未遮蔽）。
  final String buffer;

  /// 是否以圆点遮蔽显示。
  final bool obscure;

  /// 是否为当前聚焦的输入框。
  final bool isActive;

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
    final display = displayPin(buffer, obscure);
    return Semantics(
      label: label,
      value: display,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: _PinDotRow(buffer: buffer, obscure: obscure, isActive: isActive),
      ),
    );
  }
}

/// 6 位 PIN 圆点展示行：已填写位加深，未填写为浅色。
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
  static const _spacing = 2.0;

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
    final isHighlighted = isFilled;
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
