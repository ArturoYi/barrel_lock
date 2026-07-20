import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 添加密码入口：用于 AppBar 区域的圆形主操作按钮。
class VaultAddPasswordButton extends StatelessWidget {
  const VaultAddPasswordButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                '添加',
                style: context.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
