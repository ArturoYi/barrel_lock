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

  static const _animationDuration = Duration(milliseconds: 220);
  static const _animationCurve = Curves.easeOutCubic;

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
                AnimatedRotation(
                  turns: isCollapsed ? 0 : 0.25,
                  duration: _animationDuration,
                  curve: _animationCurve,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.primary,
                  ),
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
        AnimatedSize(
          duration: _animationDuration,
          curve: _animationCurve,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: isCollapsed
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < group.items.length; i++) ...[
                      VaultCipherCard(
                        item: group.items[i],
                        onTap: () => onCipherTapped(group.items[i].id),
                        onFavoriteToggled: () =>
                            onFavoriteToggled(group.items[i].id),
                      ),
                      if (i < group.items.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
