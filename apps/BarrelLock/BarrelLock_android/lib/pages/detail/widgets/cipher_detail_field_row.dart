import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 详情页只读字段行：标签、值、复制、敏感字段掩码。
class CipherDetailFieldRow extends StatelessWidget {
  const CipherDetailFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.fieldKey,
    required this.isRevealed,
    required this.onToggleReveal,
    required this.onCopy,
    this.isSensitive = false,
    this.multiline = false,
  });

  final String label;
  final String value;
  final String fieldKey;
  final bool isRevealed;
  final bool isSensitive;
  final bool multiline;
  final VoidCallback onToggleReveal;
  final Future<void> Function(String value) onCopy;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = context.colors;
    final displayValue = isSensitive && !isRevealed ? '••••••••' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            crossAxisAlignment: multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayValue,
                      style: context.textTheme.bodyLarge,
                      maxLines: multiline ? null : 2,
                      overflow: multiline ? null : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSensitive)
                IconButton(
                  tooltip: isRevealed ? '隐藏' : '显示',
                  onPressed: onToggleReveal,
                  icon: Icon(
                    isRevealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              IconButton(
                tooltip: '复制',
                onPressed: () => onCopy(value),
                icon: const Icon(Icons.copy_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData cipherTypeIconFor(String iconName) => switch (iconName) {
  'language' => Icons.language,
  'credit_card' => Icons.credit_card,
  'badge' => Icons.badge_outlined,
  'sticky_note_2' => Icons.sticky_note_2_outlined,
  'vpn_key' => Icons.vpn_key_outlined,
  'smartphone' => Icons.smartphone_outlined,
  _ => Icons.lock_outline,
};
