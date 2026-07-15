import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 密码条目卡片：网站图标 + 标题 + 副标题 + 收藏星标。
class VaultCipherCard extends StatelessWidget {
  const VaultCipherCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavoriteToggled,
  });

  final CipherOverviewItem item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _SiteIcon(host: item.host, title: item.title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: item.isFavorite ? '取消收藏' : '收藏',
                onPressed: onFavoriteToggled,
                icon: Icon(
                  item.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: item.isFavorite
                      ? colorScheme.tertiary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SiteIcon extends StatelessWidget {
  const _SiteIcon({required this.title, this.host});

  final String title;
  final String? host;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final label = (host?.isNotEmpty ?? false)
        ? host!.characters.first.toUpperCase()
        : title.characters.first.toUpperCase();

    return CircleAvatar(
      radius: 22,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        label,
        style: context.textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
