import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 键盘底部行左右键位；为 null 时保留等宽占位。
final class AppLockPinKeyAction {
  const AppLockPinKeyAction({
    required this.child,
    required this.onPressed,
    this.semanticLabel,
  });

  /// 键位内容，通常为 [Icon] 或 [Text]。
  final Widget child;

  final VoidCallback? onPressed;

  /// 无障碍朗读标签；传入 [Icon] 时建议设置。
  final String? semanticLabel;
}

/// PIN 输入自定义数字键盘（不触发系统键盘）。
final class AppLockPinKeypad extends StatelessWidget {
  const AppLockPinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.enabled,
    required this.isFull,
    this.leadingKey,
    this.trailingKey,
  });

  final ValueChanged<int> onDigitPressed;
  final bool enabled;
  final bool isFull;

  /// 第 4 行第 1 列（0 左侧）键位。
  final AppLockPinKeyAction? leadingKey;

  /// 第 4 行第 3 列（0 右侧）键位。
  final AppLockPinKeyAction? trailingKey;

  static const _digits = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  static const _keyWidth = 82.0;
  static const _keyHeight = 76.0;
  static const _keyPadding = 6.0;
  static const _cellWidth = _keyWidth + _keyPadding * 2;
  static const _cellHeight = _keyHeight + _keyPadding * 2;
  static const _crossAxisCount = 3;
  static const _rowCount = 4;

  /// 设计稿最大尺寸；可用空间更大时不放大，更小时按短边等比缩小。
  static const maxWidth = _cellWidth * _crossAxisCount;
  static const maxHeight = _cellHeight * _rowCount;

  /// 避免极端小屏下键位过小；正常竖屏不应触发。
  static const _minScale = 0.82;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = _resolveScale(context, constraints);
        final renderWidth = maxWidth * scale;
        final renderHeight = maxHeight * scale;

        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: renderWidth,
            height: renderHeight,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox(
                width: maxWidth,
                height: maxHeight,
                child: _KeypadGrid(
                  onDigitPressed: onDigitPressed,
                  enabled: enabled,
                  isFull: isFull,
                  leadingKey: leadingKey,
                  trailingKey: trailingKey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static double _resolveScale(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final orientation = MediaQuery.orientationOf(context);
    final media = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    var availableWidth = constraints.maxWidth;
    if (!availableWidth.isFinite) {
      availableWidth = media.width - padding.horizontal;
    }

    var availableHeight = constraints.maxHeight;
    if (!availableHeight.isFinite) {
      availableHeight = media.height - padding.vertical;
    }

    final widthScale = availableWidth / maxWidth;
    final heightScale = availableHeight / maxHeight;

    final double scale;
    if (orientation == Orientation.portrait) {
      // 竖屏以宽度为主；仅当按宽度算出的高度超出可用高度时才进一步缩小。
      scale = math.min(widthScale, 1);
      final scaledHeight = maxHeight * scale;
      if (scaledHeight > availableHeight) {
        return math.max(math.min(scale, heightScale), _minScale);
      }
    } else {
      // 横屏按短边等比适配，防止高度溢出。
      scale = math.min(math.min(widthScale, heightScale), 1);
    }

    return math.max(scale, _minScale).clamp(0, 1);
  }
}

final class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({
    required this.onDigitPressed,
    required this.enabled,
    required this.isFull,
    required this.leadingKey,
    required this.trailingKey,
  });

  final ValueChanged<int> onDigitPressed;
  final bool enabled;
  final bool isFull;
  final AppLockPinKeyAction? leadingKey;
  final AppLockPinKeyAction? trailingKey;

  @override
  Widget build(BuildContext context) {
    final canEnterDigit = enabled && !isFull;

    return GridView.count(
      crossAxisCount: AppLockPinKeypad._crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      childAspectRatio:
          AppLockPinKeypad._cellWidth / AppLockPinKeypad._cellHeight,
      children: [
        for (final digit in AppLockPinKeypad._digits)
          _KeyButton(
            isDigit: true,
            onPressed: canEnterDigit ? () => onDigitPressed(digit) : null,
            child: Text('$digit'),
          ),
        _buildSideKey(leadingKey),
        _KeyButton(
          isDigit: true,
          onPressed: canEnterDigit ? () => onDigitPressed(0) : null,
          child: const Text('0'),
        ),
        _buildSideKey(trailingKey),
      ],
    );
  }

  Widget _buildSideKey(AppLockPinKeyAction? action) {
    if (action == null) {
      return const _KeyPlaceholder();
    }
    return _KeyButton(
      semanticLabel: action.semanticLabel,
      onPressed: enabled ? action.onPressed : null,
      child: action.child,
    );
  }
}

final class _KeyPlaceholder extends StatelessWidget {
  const _KeyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppLockPinKeypad._keyPadding),
      child: SizedBox(
        width: AppLockPinKeypad._keyWidth,
        height: AppLockPinKeypad._keyHeight,
      ),
    );
  }
}

final class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.isDigit = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool isDigit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onPressed != null;
    final foregroundColor = isEnabled
        ? (isDigit ? colors.primary : colors.onSurface)
        : colors.onSurface.withValues(alpha: 0.38);

    final button = Padding(
      padding: const EdgeInsets.all(AppLockPinKeypad._keyPadding),
      child: SizedBox(
        width: AppLockPinKeypad._keyWidth,
        height: AppLockPinKeypad._keyHeight,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.surfaceContainerLow,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: colors.surfaceContainerLow.withValues(
              alpha: 0.6,
            ),
            disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: onPressed,
          child: isDigit
              ? DefaultTextStyle(
                  style:
                      context.textTheme.titleLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(color: foregroundColor),
                  child: child,
                )
              : IconTheme(
                  data: IconThemeData(color: foregroundColor, size: 24),
                  child: DefaultTextStyle(
                    style:
                        context.textTheme.labelLarge?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(color: foregroundColor),
                    child: child,
                  ),
                ),
        ),
      ),
    );

    if (semanticLabel case final label?) {
      return Semantics(label: label, button: true, child: button);
    }
    return button;
  }
}
