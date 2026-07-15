import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'vault_cipher_card.dart';

/// 可折叠的文件夹分组。
class VaultFolderSection extends StatelessWidget {
  const VaultFolderSection({
    super.key,
    required this.group,
    required this.isCollapsed,
    required this.onCollapseToggled,
    required this.onCipherTapped,
    required this.onFavoriteToggled,
  });

  final VaultFolderGroup group;
  final bool isCollapsed;
  final VoidCallback onCollapseToggled;
  final ValueChanged<String> onCipherTapped;
  final ValueChanged<String> onFavoriteToggled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onCollapseToggled,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Row(
              children: [
                Icon(
                  isCollapsed
                      ? Icons.chevron_right_rounded
                      : Icons.expand_more_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    group.name,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${group.items.length}',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isCollapsed) ...[
          for (var i = 0; i < group.items.length; i++) ...[
            VaultCipherCard(
              item: group.items[i],
              onTap: () => onCipherTapped(group.items[i].id),
              onFavoriteToggled: () => onFavoriteToggled(group.items[i].id),
            ),
            if (i < group.items.length - 1) const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}
