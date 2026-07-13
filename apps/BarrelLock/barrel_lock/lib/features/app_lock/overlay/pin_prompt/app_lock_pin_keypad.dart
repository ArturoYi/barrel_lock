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
  static const _keyWidth = 72.0;
  static const _keyHeight = 56.0;
  static const _keyPadding = 6.0;
  static const _cellWidth = _keyWidth + _keyPadding * 2;
  static const _cellHeight = _keyHeight + _keyPadding * 2;
  static const _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    final canEnterDigit = enabled && !isFull;

    return Center(
      child: SizedBox(
        width: _cellWidth * _crossAxisCount,
        child: GridView.count(
          crossAxisCount: _crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: _cellWidth / _cellHeight,
          children: [
            for (final digit in _digits)
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
        ),
      ),
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
