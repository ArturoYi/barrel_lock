import 'package:flutter/material.dart';

/// PIN 输入自定义数字键盘（不触发系统键盘）。
final class AppLockPinKeypad extends StatelessWidget {
  const AppLockPinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
    required this.enabled,
    required this.isFull,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;
  final bool enabled;
  final bool isFull;

  static const _digits = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
    final canEnterDigit = enabled && !isFull;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var col = 0; col < 3; col++)
                _KeyButton(
                  label: '${_digits[row * 3 + col]}',
                  onPressed: canEnterDigit
                      ? () => onDigitPressed(_digits[row * 3 + col])
                      : null,
                ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeyButton(label: '清除', onPressed: enabled ? onClearPressed : null),
            _KeyButton(
              label: '0',
              onPressed: canEnterDigit ? () => onDigitPressed(0) : null,
            ),
            _KeyButton(
              label: '删除',
              onPressed: enabled ? onDeletePressed : null,
            ),
          ],
        ),
      ],
    );
  }
}

final class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 72,
        height: 56,
        child: FilledButton.tonal(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
