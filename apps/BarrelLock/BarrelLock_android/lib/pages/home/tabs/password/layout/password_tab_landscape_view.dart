import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/vault_folder_section.dart';
import '../widgets/vault_quick_filter_row.dart';
import '../widgets/vault_search_bar.dart';
import '../widgets/vault_switcher_button.dart';

/// 密码 Tab 横屏布局：顶栏工具区 + 可滚动分组列表。
class PasswordTabLandscapeView extends StatelessWidget {
  const PasswordTabLandscapeView({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [colorScheme.primary, colorScheme.primaryContainer],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 8,
              20,
              14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      state.title,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    VaultSwitcherButton(
                      vaults: state.vaults,
                      selectedVault: state.selectedVault,
                      onVaultSelected: onVaultSelected,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                VaultSearchBar(
                  query: state.searchQuery,
                  onChanged: onSearchChanged,
                ),
                const SizedBox(height: 12),
                VaultQuickFilterRow(
                  selected: state.quickFilter,
                  onSelected: onQuickFilterSelected,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: state.totalItemCount == 0
              ? Center(
                  child: Text(
                    '暂无密码条目',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: state.folderGroups.length,
                  itemBuilder: (context, index) {
                    final group = state.folderGroups[index];
                    return VaultFolderSection(
                      group: group,
                      isCollapsed: state.isFolderCollapsed(group.id),
                      onCollapseToggled: () =>
                          onFolderCollapseToggled(group.id),
                      onCipherTapped: onCipherTapped,
                      onFavoriteToggled: onFavoriteToggled,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
