import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/vault_folder_section.dart';
import '../widgets/vault_home_gradient_background.dart';
import '../widgets/vault_home_search_row.dart';
import '../widgets/vault_quick_filter_row.dart';

/// 密码 Tab 竖屏布局：顶部搜索 + 快捷筛选 + 分组列表。
class PasswordTabPortraitView extends StatelessWidget {
  const PasswordTabPortraitView({
    super.key,
    required this.state,
    required this.onSearchChanged,
    required this.onQuickFilterSelected,
    required this.onVaultSelected,
    required this.onFolderCollapseToggled,
    required this.onFavoriteToggled,
    required this.onCipherTapped,
  });

  final PasswordTabViewState state;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<VaultQuickFilter> onQuickFilterSelected;
  final ValueChanged<String> onVaultSelected;
  final ValueChanged<String> onFolderCollapseToggled;
  final ValueChanged<String> onFavoriteToggled;
  final ValueChanged<String> onCipherTapped;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _VaultHomeHeader(
            state: state,
            onSearchChanged: onSearchChanged,
            onQuickFilterSelected: onQuickFilterSelected,
            onVaultSelected: onVaultSelected,
          ),
        ),
        if (state.totalItemCount == 0)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                '暂无密码条目',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => VaultFolderSection(
                  group: state.folderGroups[index],
                  isCollapsed: state.isFolderCollapsed(
                    state.folderGroups[index].id,
                  ),
                  onCollapseToggled: () =>
                      onFolderCollapseToggled(state.folderGroups[index].id),
                  onCipherTapped: onCipherTapped,
                  onFavoriteToggled: onFavoriteToggled,
                ),
                childCount: state.folderGroups.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _VaultHomeHeader extends StatelessWidget {
  const _VaultHomeHeader({
    required this.state,
    required this.onSearchChanged,
    required this.onQuickFilterSelected,
    required this.onVaultSelected,
  });

  final PasswordTabViewState state;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<VaultQuickFilter> onQuickFilterSelected;
  final ValueChanged<String> onVaultSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Stack(
      children: [
        Positioned.fill(
          child: VaultHomeGradientBackground(colorScheme: colorScheme),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + 12,
            16,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.title,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              VaultHomeSearchRow(
                query: state.searchQuery,
                onChanged: onSearchChanged,
                vaults: state.vaults,
                selectedVault: state.selectedVault,
                onVaultSelected: onVaultSelected,
              ),
              const SizedBox(height: 14),
              VaultQuickFilterRow(
                selected: state.quickFilter,
                onSelected: onQuickFilterSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
