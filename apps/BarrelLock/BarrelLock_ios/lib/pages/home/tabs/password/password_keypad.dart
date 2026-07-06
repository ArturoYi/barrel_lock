import 'package:flutter/material.dart';

/// 密码 Tab 数字键盘（横竖屏共用）。
class PasswordKeypad extends StatelessWidget {
  const PasswordKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
    required this.isComplete,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;
  final bool isComplete;

  static const _digits = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
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
                  onPressed: isComplete
                      ? null
                      : () => onDigitPressed(_digits[row * 3 + col]),
                ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeyButton(label: '清除', onPressed: onClearPressed),
            _KeyButton(
              label: '0',
              onPressed: isComplete ? null : () => onDigitPressed(0),
            ),
            _KeyButton(label: '删除', onPressed: onDeletePressed),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
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
