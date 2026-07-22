import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/vault_add_password_button.dart';
import '../widgets/vault_folder_section.dart';
import '../widgets/vault_home_gradient_background.dart';
import '../widgets/vault_home_search_row.dart';
import '../widgets/vault_quick_filter_row.dart';

/// 密码 Tab 竖屏布局：固定顶栏 + 可滚动分组列表。
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
    required this.onAddPasswordTapped,
    required this.onCreateVaultTapped,
  });

  final PasswordTabViewState state;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<VaultQuickFilter> onQuickFilterSelected;
  final ValueChanged<String> onVaultSelected;
  final ValueChanged<String> onFolderCollapseToggled;
  final ValueChanged<String> onFavoriteToggled;
  final ValueChanged<String> onCipherTapped;
  final VoidCallback onAddPasswordTapped;
  final VoidCallback onCreateVaultTapped;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VaultHomeHeader(
          state: state,
          onSearchChanged: onSearchChanged,
          onQuickFilterSelected: onQuickFilterSelected,
          onVaultSelected: onVaultSelected,
          onAddPasswordTapped: onAddPasswordTapped,
          onCreateVaultTapped: onCreateVaultTapped,
        ),
        Expanded(
          child: !state.hasVaults
              ? _NoVaultEmptyState(
                  colorScheme: colorScheme,
                  onCreateVaultTapped: onCreateVaultTapped,
                  onAddPasswordTapped: onAddPasswordTapped,
                )
              : state.totalItemCount == 0
              ? _EmptyPasswordList(
                  colorScheme: colorScheme,
                  onAddPasswordTapped: onAddPasswordTapped,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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

class _NoVaultEmptyState extends StatelessWidget {
  const _NoVaultEmptyState({
    required this.colorScheme,
    required this.onCreateVaultTapped,
    required this.onAddPasswordTapped,
  });

  final ColorScheme colorScheme;
  final VoidCallback onCreateVaultTapped;
  final VoidCallback onAddPasswordTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无保险库',
              style: context.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '创建保险库以开始管理密码',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreateVaultTapped,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('创建保险库'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddPasswordTapped,
              icon: const Icon(Icons.add_rounded),
              label: const Text('添加密码'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPasswordList extends StatelessWidget {
  const _EmptyPasswordList({
    required this.colorScheme,
    required this.onAddPasswordTapped,
  });

  final ColorScheme colorScheme;
  final VoidCallback onAddPasswordTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_open_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无密码条目',
              style: context.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddPasswordTapped,
              icon: const Icon(Icons.add_rounded),
              label: const Text('添加密码'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultHomeHeader extends StatelessWidget {
  const _VaultHomeHeader({
    required this.state,
    required this.onSearchChanged,
    required this.onQuickFilterSelected,
    required this.onVaultSelected,
    required this.onAddPasswordTapped,
    required this.onCreateVaultTapped,
  });

  final PasswordTabViewState state;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<VaultQuickFilter> onQuickFilterSelected;
  final ValueChanged<String> onVaultSelected;
  final VoidCallback onAddPasswordTapped;
  final VoidCallback onCreateVaultTapped;

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
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    state.title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: VaultAddPasswordButton(
                      onPressed: onAddPasswordTapped,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.hasVaults && state.selectedVault != null) ...[
                VaultHomeSearchRow(
                  query: state.searchQuery,
                  onChanged: onSearchChanged,
                  vaults: state.vaults,
                  selectedVault: state.selectedVault!,
                  onVaultSelected: onVaultSelected,
                  onCreateVault: onCreateVaultTapped,
                ),
                const SizedBox(height: 14),
                VaultQuickFilterRow(
                  selected: state.quickFilter,
                  onSelected: onQuickFilterSelected,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
