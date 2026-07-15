import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 快捷入口横滑：全部 / 收藏 / 最近使用 / TOTP。
class VaultQuickFilterRow extends StatelessWidget {
  const VaultQuickFilterRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final VaultQuickFilter selected;
  final ValueChanged<VaultQuickFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: VaultQuickFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = VaultQuickFilter.values[index];
          return _FilterChip(
            filter: filter,
            isSelected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  final VaultQuickFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.95)
          : colorScheme.surface.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                size: 16,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                filter.label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
