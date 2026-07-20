import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 添加页 cipher 类型选择行（展示全部 6 类）。
final class CipherTypeSelector extends StatelessWidget {
  const CipherTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final int selectedType;
  final ValueChanged<int> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          for (final descriptor in CipherTypeCatalog.all) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(descriptor.label),
                selected: selectedType == descriptor.type,
                onSelected: descriptor.isFormEnabled
                    ? (_) => onTypeSelected(descriptor.type)
                    : null,
                avatar: Icon(
                  _iconFor(descriptor.iconName),
                  size: 18,
                  color: descriptor.isFormEnabled
                      ? null
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                showCheckmark: false,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _iconFor(String iconName) => switch (iconName) {
    'language' => Icons.language,
    'credit_card' => Icons.credit_card,
    'badge' => Icons.badge_outlined,
    'sticky_note_2' => Icons.sticky_note_2_outlined,
    'vpn_key' => Icons.vpn_key_outlined,
    'smartphone' => Icons.smartphone_outlined,
    _ => Icons.lock_outline,
  };
}
